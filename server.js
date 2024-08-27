require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
app.use(express.json());
app.use(cors());
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "http://127.0.0.1:5500",
        methods: ["GET", "POST"]
    }
});

// Configuration de la base de données
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'hacker_challenge_db'
};

let db;

async function connectDB() {
    try {
        db = await mysql.createConnection(dbConfig);
        console.log('Connecté à la base de données MySQL');
    } catch (error) {
        console.error('Erreur de connexion à la base de données:', error);
        process.exit(1);
    }
}

connectDB();

// Middleware de gestion des erreurs
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Une erreur est survenue sur le serveur' });
});

// Route pour l'inscription
app.post('/register', async (req, res, next) => {
    const { username, email, password } = req.body;

    try {
        const [existingUsers] = await db.execute('SELECT * FROM users WHERE username = ? OR email = ?', [username, email]);
        
        if (existingUsers.length > 0) {
            return res.status(409).json({ message: 'Nom d\'utilisateur ou email déjà utilisé' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        await db.execute('INSERT INTO users (username, email, password_hash, jokers_left) VALUES (?, ?, ?, 3)', [username, email, hashedPassword]);
        
        res.status(201).json({ message: 'Inscription réussie' });
    } catch (error) {
        next(error);
    }
});
//route pour charger les conversation
app.get('/conversation-history/:username', async (req, res) => {
    const { username } = req.params;
    try {
        const [questions] = await db.execute('SELECT * FROM questions WHERE username = ? ORDER BY created_at ASC', [username]);
        res.json(questions.map(q => ({
            text: q.question,
            isQuestion: true
        })).concat(questions.filter(q => q.answer).map(q => ({
            text: q.answer,
            isQuestion: false
        }))));
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'historique:', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
});
// Route pour la connexion
app.post('/login', async (req, res, next) => {
    const { username, password } = req.body;
  
    try {
        const [users] = await db.execute('SELECT * FROM users WHERE username = ?', [username]);
        
        if (users.length === 0) {
            return res.status(401).json({ message: "Nom d'utilisateur ou mot de passe incorrect" });
        }

        const user = users[0];
        const match = await bcrypt.compare(password, user.password_hash);
        
        if (match) {
            res.json({ 
                message: 'Connexion réussie', 
                username: user.username, 
                jokersLeft: user.jokers_left 
            });
        } else {
            res.status(401).json({ message: "Nom d'utilisateur ou mot de passe incorrect" });
        }
    } catch (error) {
        next(error);
    }
});

// Route pour obtenir les informations de l'utilisateur
app.get('/user-info/:username', async (req, res, next) => {
    const { username } = req.params;
    try {
        const [users] = await db.execute('SELECT username, jokers_left FROM users WHERE username = ?', [username]);
        if (users.length > 0) {
            res.json(users[0]);
        } else {
            res.status(404).json({ message: 'Utilisateur non trouvé' });
        }
    } catch (error) {
        next(error);
    }
});

// Variable globale pour les réponses automatiques
let autoResponseEnabled = false;

// Routes admin
app.get('/admin/questions', async (req, res, next) => {
    try {
        const [questions] = await db.execute('SELECT * FROM questions ORDER BY created_at DESC');
        res.json(questions);
    } catch (error) {
        next(error);
    }
});

app.post('/admin/answer', async (req, res, next) => {
    const { questionId, answer } = req.body;
    try {
        await db.execute('UPDATE questions SET answer = ?, answered = TRUE WHERE id = ?', [answer, questionId]);
        res.json({ success: true });
    } catch (error) {
        next(error);
    }
});

app.post('/admin/toggle-auto-response', (req, res) => {
    autoResponseEnabled = !autoResponseEnabled;
    res.json({ autoResponseEnabled });
});

app.get('/admin/auto-response-status', (req, res) => {
    res.json({ autoResponseEnabled });
});

// Configuration Socket.IO
io.on('connection', (socket) => {
    console.log('Un client s\'est connecté');
  
    socket.on('askQuestion', async (data) => {
        const { username, question } = data;
        try {
            await db.execute('INSERT INTO questions (username, question) VALUES (?, ?)', [username, question]);
            await db.execute('UPDATE users SET jokers_left = jokers_left - 1 WHERE username = ?', [username]);
            
            io.to('admin').emit('newQuestion', { username, question });
            
            socket.emit('questionReceived', { message: "Votre question a été reçue. Un administrateur y répondra bientôt." });
        } catch (error) {
            console.error('Erreur lors de l\'enregistrement de la question:', error);
            socket.emit('error', { message: "Une erreur est survenue lors de l'envoi de votre question." });
        }
    });
  
    socket.on('adminAnswer', async (data) => {
        const { questionId, answer } = data;
        try {
            const [questionDetails] = await db.execute('SELECT username, question FROM questions WHERE id = ?', [questionId]);
            await db.execute('UPDATE questions SET answer = ?, answered = TRUE WHERE id = ?', [answer, questionId]);
            
            const username = questionDetails[0].username;
            const question = questionDetails[0].question;
    
            io.to(username).emit('answerReceived', { questionId, question, answer });
        } catch (error) {
            console.error('Erreur lors de l\'enregistrement de la réponse:', error);
            socket.emit('error', { message: "Une erreur est survenue lors de l'envoi de la réponse." });
        }
    });
  
    socket.on('adminLogin', (data) => {
        // Note: Implémentez une authentification plus sécurisée en production
        if (data.adminPassword === 'motDePasseAdmin') {
            socket.join('admin');
            socket.emit('adminLoggedIn', { message: "Connecté en tant qu'administrateur" });
        }
    });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Serveur en écoute sur le port ${PORT}`));