#!/bin/bash

# AAA - The Amazing Alternative to Awesome
# Setup script - Run this in an empty directory or your cloned repo

echo "🧘 Setting up AAA - The Amazing Alternative to Awesome..."

# Create public directory
mkdir -p public

# Create .gitignore
cat > .gitignore << 'GITIGNORE_EOF'
# Dependencies
node_modules/

# Environment variables
.env
.env.local
.env.*.local

# Logs
*.log
npm-debug.log*

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Build output
dist/
build/
GITIGNORE_EOF

echo "✓ Created .gitignore"

# Create package.json
cat > package.json << 'PACKAGE_EOF'
{
  "name": "aaa-yoga-app",
  "version": "1.0.0",
  "description": "The Amazing Alternative to Awesome - Mindful language for yoga teachers",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js"
  },
  "keywords": ["yoga", "teaching", "mindful", "language"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^5.2.1",
    "openai": "^6.17.0"
  }
}
PACKAGE_EOF

echo "✓ Created package.json"

# Create server.js
cat > server.js << 'SERVER_EOF'
const express = require('express');
const OpenAI = require('openai');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 12000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Single-word alternatives to "awesome" (never includes "awesome" or "amazing")
const awesomeAlternatives = [
  'wonderful', 'beautiful', 'excellent', 'fantastic', 'magnificent',
  'brilliant', 'outstanding', 'remarkable', 'exceptional', 'superb',
  'splendid', 'marvelous', 'terrific', 'fabulous', 'glorious',
  'stunning', 'impressive', 'phenomenal', 'extraordinary', 'sublime',
  'radiant', 'graceful', 'elegant', 'powerful', 'steady',
  'strong', 'balanced', 'centered', 'grounded', 'focused',
  'mindful', 'present', 'aligned', 'engaged', 'intentional'
];

// Random word endpoint
app.get('/api/random-word', (req, res) => {
  const randomIndex = Math.floor(Math.random() * awesomeAlternatives.length);
  res.json({ word: awesomeAlternatives[randomIndex] });
});

// AI-powered contextual cue endpoint
app.post('/api/generate-cue', async (req, res) => {
  const { phrase } = req.body;
  
  if (!phrase || phrase.trim() === '') {
    return res.status(400).json({ error: 'Please provide a phrase' });
  }

  // Check if OpenAI API key is available
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    // Fallback response if no API key
    return res.json({ 
      cue: getFallbackCue(phrase),
      note: 'Using fallback mode. Set OPENAI_API_KEY for AI-powered cues.'
    });
  }

  try {
    const openai = new OpenAI({ apiKey });
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are an expert yoga instructor helping other yoga teachers find better alternatives to saying "awesome" in their classes.

IMPORTANT RULES:
- NEVER use the words "awesome" or "amazing" in your responses
- Provide specific, instructive feedback that helps students understand their alignment and form
- If a yoga pose is mentioned (in English or Sanskrit), provide a cue specific to that pose
- If no specific pose is mentioned, select a random common yoga pose and create a cue for it
- Focus on alignment, breath, engagement, or sensation cues
- Keep responses concise and suitable for use during a yoga class
- The cue should be encouraging but instructive, not cheerleading

Examples of good cues:
- "I love how your front knee is tracking over your ankle in Warrior II"
- "Beautiful extension through your spine in Downward Dog"
- "Notice how grounded your standing leg feels in Tree Pose"
- "Your hip alignment in Pigeon is looking wonderful today"`
        },
        {
          role: 'user',
          content: `A yoga teacher wants to say "${phrase}" to their students. Provide an alternative phrase that:
1. Does NOT use "awesome" or "amazing"
2. Includes a specific, instructive cue about the pose
3. Is encouraging but educational

Respond with just the alternative cue, nothing else.`
        }
      ],
      max_tokens: 150,
      temperature: 0.8
    });

    const cue = completion.choices[0].message.content.trim();
    
    // Double-check the response doesn't contain forbidden words
    if (cue.toLowerCase().includes('awesome') || cue.toLowerCase().includes('amazing')) {
      return res.json({ cue: getFallbackCue(phrase) });
    }
    
    res.json({ cue });
  } catch (error) {
    console.error('OpenAI API error:', error);
    res.json({ 
      cue: getFallbackCue(phrase),
      note: 'AI service unavailable. Using fallback response.'
    });
  }
});

// Fallback cue generator when AI is not available
function getFallbackCue(phrase) {
  const phraseLower = phrase.toLowerCase();
  
  // Common yoga poses with specific cues
  const poseCues = {
    'warrior i': 'Your back foot grounding and hip alignment in Warrior I is looking strong and steady.',
    'warrior ii': 'I love how your front knee is tracking beautifully over your ankle in Warrior II.',
    'warrior iii': 'Notice the wonderful line of energy from your fingertips through your back heel in Warrior III.',
    'virabhadrasana i': 'Your back foot grounding and hip alignment in Warrior I is looking strong and steady.',
    'virabhadrasana ii': 'I love how your front knee is tracking beautifully over your ankle in Warrior II.',
    'virabhadrasana iii': 'Notice the wonderful line of energy from your fingertips through your back heel in Warrior III.',
    'downward dog': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'down dog': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'adho mukha svanasana': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'tree': 'Your standing leg looks wonderfully grounded - feel that stability rising up through your spine in Tree Pose.',
    'vrksasana': 'Your standing leg looks wonderfully grounded - feel that stability rising up through your spine in Tree Pose.',
    'triangle': 'Excellent extension through both sides of your waist in Triangle - keep that beautiful length.',
    'trikonasana': 'Excellent extension through both sides of your waist in Triangle - keep that beautiful length.',
    'chair': 'Your weight is beautifully distributed through your heels in Chair Pose - feel that strength in your thighs.',
    'utkatasana': 'Your weight is beautifully distributed through your heels in Chair Pose - feel that strength in your thighs.',
    'cobra': 'Notice the elegant lift through your heart center in Cobra - shoulders drawing down beautifully.',
    'bhujangasana': 'Notice the elegant lift through your heart center in Cobra - shoulders drawing down beautifully.',
    'child': 'Your breath is flowing wonderfully in Child\'s Pose - let your hips sink back toward your heels.',
    'balasana': 'Your breath is flowing wonderfully in Child\'s Pose - let your hips sink back toward your heels.',
    'pigeon': 'Your hip alignment in Pigeon is looking balanced and steady - breathe into that stretch.',
    'eka pada rajakapotasana': 'Your hip alignment in Pigeon is looking balanced and steady - breathe into that stretch.',
    'crow': 'Wonderful engagement through your core in Crow - your gaze is focused and steady.',
    'bakasana': 'Wonderful engagement through your core in Crow - your gaze is focused and steady.',
    'plank': 'Your body is making one beautiful line from head to heels in Plank - strong core engagement.',
    'bridge': 'Notice how your thighs are parallel and your feet grounded in Bridge - beautiful lift through your hips.',
    'setu bandhasana': 'Notice how your thighs are parallel and your feet grounded in Bridge - beautiful lift through your hips.',
    'mountain': 'Your alignment in Mountain Pose is wonderfully tall - feel the energy rising through your crown.',
    'tadasana': 'Your alignment in Mountain Pose is wonderfully tall - feel the energy rising through your crown.',
    'corpse': 'Allow your body to completely release in Savasana - you\'ve done wonderful work today.',
    'savasana': 'Allow your body to completely release in Savasana - you\'ve done wonderful work today.'
  };

  // Check if any pose is mentioned in the phrase
  for (const [pose, cue] of Object.entries(poseCues)) {
    if (phraseLower.includes(pose)) {
      return cue;
    }
  }

  // Random pose cues for when no specific pose is mentioned
  const randomCues = [
    'Your alignment is looking wonderfully steady - notice how grounded your foundation feels.',
    'Beautiful breath awareness - let that steady inhale and exhale guide your movement.',
    'I love seeing your focused intention in this pose - your body is responding beautifully.',
    'Notice the elegant strength you\'re building - your form is looking balanced and centered.',
    'Your practice is showing wonderful progress - stay present with each breath.',
    'Feel how steady and grounded your stance is - that\'s excellent body awareness.',
    'Your dedication to proper form is evident - keep that mindful engagement.',
    'Notice the beautiful connection between your breath and movement today.'
  ];

  return randomCues[Math.floor(Math.random() * randomCues.length)];
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🧘 The Amazing Alternative to Awesome (AAA) is running on port ${PORT}`);
  console.log(`   Visit: http://localhost:${PORT}`);
});
SERVER_EOF

echo "✓ Created server.js"

# Create public/index.html
cat > public/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AAA - The Amazing Alternative to Awesome</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600&family=Nunito:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="app-container">
    <!-- Decorative elements -->
    <div class="lotus-decoration top-left"></div>
    <div class="lotus-decoration bottom-right"></div>
    
    <!-- Header -->
    <header class="header">
      <div class="logo">
        <span class="logo-icon">🧘</span>
        <div class="logo-text">
          <h1>AAA</h1>
          <p class="tagline">The Amazing Alternative to Awesome</p>
        </div>
      </div>
      <p class="subtitle">Mindful language for yoga teachers</p>
    </header>

    <!-- Main content -->
    <main class="main-content">
      <!-- Random Word Section -->
      <section class="card random-section">
        <h2>Quick Inspiration</h2>
        <p class="section-description">Need a quick alternative? Let the universe guide you.</p>
        
        <button id="randomBtn" class="btn btn-primary">
          <span class="btn-icon">✨</span>
          Random Awesomeness
        </button>
        
        <div id="randomResult" class="result-box hidden">
          <p class="result-label">Try saying:</p>
          <p id="randomWord" class="result-word"></p>
        </div>
      </section>

      <!-- Contextual Cue Section -->
      <section class="card cue-section">
        <h2>Contextual Cues</h2>
        <p class="section-description">Enter a phrase you'd normally say, and receive an instructive alternative with specific yoga cues.</p>
        
        <div class="input-group">
          <label for="phraseInput" class="input-label">Your phrase:</label>
          <input 
            type="text" 
            id="phraseInput" 
            class="text-input" 
            placeholder="e.g., Awesome Warrior II!"
            maxlength="200"
          >
          <p class="input-hint">Include a pose name (English or Sanskrit) for pose-specific cues</p>
        </div>
        
        <button id="generateBtn" class="btn btn-secondary">
          <span class="btn-icon">🌟</span>
          Generate Mindful Cue
        </button>
        
        <div id="cueResult" class="result-box hidden">
          <p class="result-label">Instead, try:</p>
          <p id="generatedCue" class="result-cue"></p>
        </div>
        
        <div id="loading" class="loading hidden">
          <div class="spinner"></div>
          <p>Finding the perfect words...</p>
        </div>
      </section>

      <!-- Tips Section -->
      <section class="card tips-section">
        <h2>Remember</h2>
        <div class="tip-content">
          <p>🙏 Mindful feedback helps students understand <em>what</em> they're doing well</p>
          <p>🧘 Specific cues keep students safe and engaged</p>
          <p>💫 Your words guide their practice journey</p>
        </div>
      </section>
    </main>

    <!-- Footer -->
    <footer class="footer">
      <p>Made with 💙 for yoga teacher training</p>
      <p class="footer-note">Words matter. Choose them mindfully.</p>
    </footer>
  </div>

  <script src="app.js"></script>
</body>
</html>
HTML_EOF

echo "✓ Created public/index.html"

# Create public/styles.css
cat > public/styles.css << 'CSS_EOF'
/* ===================================
   AAA - The Amazing Alternative to Awesome
   Soft Light Blue Yoga Theme
   =================================== */

:root {
  /* Soft Light Blue Palette */
  --primary-light: #e8f4f8;
  --primary: #b8d4e3;
  --primary-medium: #89b4c8;
  --primary-dark: #5a8fa8;
  --accent: #7eb8c9;
  --accent-hover: #6aa8b9;
  
  /* Neutral Colors */
  --white: #ffffff;
  --cream: #fafcfd;
  --text-dark: #2c4a56;
  --text-medium: #4a6b7a;
  --text-light: #6b8a99;
  
  /* Warm Accents */
  --warm-accent: #d4a574;
  --warm-light: #f5e6d3;
  
  /* Shadows & Effects */
  --shadow-soft: 0 4px 20px rgba(90, 143, 168, 0.12);
  --shadow-medium: 0 8px 30px rgba(90, 143, 168, 0.18);
  --shadow-hover: 0 12px 40px rgba(90, 143, 168, 0.22);
  
  /* Spacing */
  --space-xs: 0.5rem;
  --space-sm: 1rem;
  --space-md: 1.5rem;
  --space-lg: 2rem;
  --space-xl: 3rem;
  
  /* Border Radius */
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 20px;
  --radius-full: 50%;
}

/* Reset & Base */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  font-size: 16px;
  scroll-behavior: smooth;
}

body {
  font-family: 'Nunito', -apple-system, BlinkMacSystemFont, sans-serif;
  font-weight: 400;
  line-height: 1.6;
  color: var(--text-dark);
  background: linear-gradient(135deg, var(--primary-light) 0%, var(--cream) 50%, var(--primary-light) 100%);
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
}

/* App Container */
.app-container {
  max-width: 600px;
  margin: 0 auto;
  padding: var(--space-md);
  min-height: 100vh;
  position: relative;
  overflow: hidden;
}

/* Decorative Elements */
.lotus-decoration {
  position: fixed;
  width: 200px;
  height: 200px;
  opacity: 0.06;
  background: radial-gradient(circle, var(--primary-dark) 0%, transparent 70%);
  border-radius: var(--radius-full);
  pointer-events: none;
  z-index: 0;
}

.lotus-decoration.top-left {
  top: -50px;
  left: -50px;
}

.lotus-decoration.bottom-right {
  bottom: -50px;
  right: -50px;
}

/* Header */
.header {
  text-align: center;
  padding: var(--space-lg) 0;
  position: relative;
  z-index: 1;
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
  margin-bottom: var(--space-sm);
}

.logo-icon {
  font-size: 2.5rem;
  animation: gentle-float 4s ease-in-out infinite;
}

@keyframes gentle-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

.logo-text h1 {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-size: 2.5rem;
  font-weight: 600;
  color: var(--primary-dark);
  letter-spacing: 0.1em;
  margin: 0;
}

.tagline {
  font-size: 0.85rem;
  color: var(--text-medium);
  font-weight: 400;
  margin: 0;
}

.subtitle {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-size: 1.1rem;
  color: var(--text-light);
  font-style: italic;
  margin-top: var(--space-xs);
}

/* Cards */
.card {
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  margin-bottom: var(--space-md);
  box-shadow: var(--shadow-soft);
  position: relative;
  z-index: 1;
  transition: box-shadow 0.3s ease, transform 0.3s ease;
}

.card:hover {
  box-shadow: var(--shadow-medium);
}

.card h2 {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-size: 1.5rem;
  font-weight: 500;
  color: var(--primary-dark);
  margin-bottom: var(--space-xs);
  text-align: center;
}

.section-description {
  font-size: 0.9rem;
  color: var(--text-light);
  text-align: center;
  margin-bottom: var(--space-md);
}

/* Buttons */
.btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
  width: 100%;
  padding: var(--space-sm) var(--space-md);
  border: none;
  border-radius: var(--radius-md);
  font-family: 'Nunito', sans-serif;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s ease;
}

.btn:hover::before {
  left: 100%;
}

.btn-primary {
  background: linear-gradient(135deg, var(--primary-medium) 0%, var(--primary-dark) 100%);
  color: var(--white);
  box-shadow: 0 4px 15px rgba(90, 143, 168, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(90, 143, 168, 0.4);
}

.btn-primary:active {
  transform: translateY(0);
}

.btn-secondary {
  background: linear-gradient(135deg, var(--accent) 0%, var(--accent-hover) 100%);
  color: var(--white);
  box-shadow: 0 4px 15px rgba(126, 184, 201, 0.3);
}

.btn-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(126, 184, 201, 0.4);
}

.btn-icon {
  font-size: 1.1rem;
}

/* Input Group */
.input-group {
  margin-bottom: var(--space-md);
}

.input-label {
  display: block;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-medium);
  margin-bottom: var(--space-xs);
}

.text-input {
  width: 100%;
  padding: var(--space-sm) var(--space-md);
  border: 2px solid var(--primary);
  border-radius: var(--radius-md);
  font-family: 'Nunito', sans-serif;
  font-size: 1rem;
  color: var(--text-dark);
  background: var(--cream);
  transition: all 0.3s ease;
}

.text-input::placeholder {
  color: var(--text-light);
  font-style: italic;
}

.text-input:focus {
  outline: none;
  border-color: var(--primary-dark);
  background: var(--white);
  box-shadow: 0 0 0 4px rgba(90, 143, 168, 0.15);
}

.input-hint {
  font-size: 0.8rem;
  color: var(--text-light);
  margin-top: var(--space-xs);
  font-style: italic;
}

/* Result Box */
.result-box {
  margin-top: var(--space-md);
  padding: var(--space-md);
  background: linear-gradient(135deg, var(--primary-light) 0%, var(--warm-light) 100%);
  border-radius: var(--radius-md);
  text-align: center;
  animation: fadeIn 0.4s ease;
  border-left: 4px solid var(--primary-dark);
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.result-label {
  font-size: 0.85rem;
  color: var(--text-light);
  margin-bottom: var(--space-xs);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.result-word {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-size: 2rem;
  font-weight: 600;
  color: var(--primary-dark);
  text-transform: capitalize;
}

.result-cue {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-size: 1.25rem;
  font-weight: 500;
  color: var(--text-dark);
  line-height: 1.5;
  font-style: italic;
}

/* Loading State */
.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-sm);
  padding: var(--space-md);
  color: var(--text-light);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--primary-light);
  border-top-color: var(--primary-dark);
  border-radius: var(--radius-full);
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Tips Section */
.tips-section {
  background: linear-gradient(135deg, var(--primary-light) 0%, var(--white) 100%);
}

.tip-content {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
}

.tip-content p {
  font-size: 0.95rem;
  color: var(--text-medium);
  padding-left: var(--space-xs);
}

.tip-content em {
  color: var(--primary-dark);
  font-style: normal;
  font-weight: 500;
}

/* Footer */
.footer {
  text-align: center;
  padding: var(--space-lg) 0;
  position: relative;
  z-index: 1;
}

.footer p {
  font-size: 0.9rem;
  color: var(--text-light);
}

.footer-note {
  font-family: 'Cormorant Garamond', Georgia, serif;
  font-style: italic;
  margin-top: var(--space-xs);
}

/* Utility Classes */
.hidden {
  display: none !important;
}

/* Responsive Design */
@media (max-width: 480px) {
  html {
    font-size: 15px;
  }
  
  .app-container {
    padding: var(--space-sm);
  }
  
  .card {
    padding: var(--space-md);
  }
  
  .logo-text h1 {
    font-size: 2rem;
  }
  
  .logo-icon {
    font-size: 2rem;
  }
  
  .result-word {
    font-size: 1.75rem;
  }
  
  .result-cue {
    font-size: 1.1rem;
  }
}

/* Touch-friendly adjustments */
@media (hover: none) {
  .btn:hover {
    transform: none;
  }
  
  .btn:active {
    transform: scale(0.98);
  }
  
  .card:hover {
    box-shadow: var(--shadow-soft);
  }
}

/* Dark mode support (optional enhancement) */
@media (prefers-color-scheme: dark) {
  /* Could add dark mode styles here if needed */
}

/* Accessibility */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Focus styles for accessibility */
.btn:focus-visible,
.text-input:focus-visible {
  outline: 3px solid var(--primary-dark);
  outline-offset: 2px;
}
CSS_EOF

echo "✓ Created public/styles.css"

# Create public/app.js
cat > public/app.js << 'JS_EOF'
// AAA - The Amazing Alternative to Awesome
// Frontend JavaScript

document.addEventListener('DOMContentLoaded', () => {
  // DOM Elements
  const randomBtn = document.getElementById('randomBtn');
  const randomResult = document.getElementById('randomResult');
  const randomWord = document.getElementById('randomWord');
  
  const phraseInput = document.getElementById('phraseInput');
  const generateBtn = document.getElementById('generateBtn');
  const cueResult = document.getElementById('cueResult');
  const generatedCue = document.getElementById('generatedCue');
  const loading = document.getElementById('loading');

  // Random Word Button Handler
  randomBtn.addEventListener('click', async () => {
    try {
      // Add button animation
      randomBtn.style.transform = 'scale(0.95)';
      setTimeout(() => {
        randomBtn.style.transform = '';
      }, 150);

      const response = await fetch('/api/random-word');
      const data = await response.json();
      
      // Hide previous result briefly for animation
      randomResult.classList.add('hidden');
      
      setTimeout(() => {
        randomWord.textContent = data.word;
        randomResult.classList.remove('hidden');
      }, 100);
      
    } catch (error) {
      console.error('Error fetching random word:', error);
      randomWord.textContent = 'wonderful';
      randomResult.classList.remove('hidden');
    }
  });

  // Generate Cue Button Handler
  generateBtn.addEventListener('click', async () => {
    const phrase = phraseInput.value.trim();
    
    if (!phrase) {
      // Shake animation for empty input
      phraseInput.style.animation = 'shake 0.5s ease';
      phraseInput.addEventListener('animationend', () => {
        phraseInput.style.animation = '';
      }, { once: true });
      phraseInput.focus();
      return;
    }

    try {
      // Show loading state
      cueResult.classList.add('hidden');
      loading.classList.remove('hidden');
      generateBtn.disabled = true;
      generateBtn.style.opacity = '0.7';

      const response = await fetch('/api/generate-cue', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ phrase }),
      });

      const data = await response.json();
      
      // Hide loading, show result
      loading.classList.add('hidden');
      generatedCue.textContent = data.cue;
      cueResult.classList.remove('hidden');
      
    } catch (error) {
      console.error('Error generating cue:', error);
      loading.classList.add('hidden');
      generatedCue.textContent = 'Your practice is looking beautifully mindful today - stay present with your breath.';
      cueResult.classList.remove('hidden');
    } finally {
      generateBtn.disabled = false;
      generateBtn.style.opacity = '';
    }
  });

  // Allow Enter key to submit phrase
  phraseInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      generateBtn.click();
    }
  });

  // Add shake animation to stylesheet dynamically
  const style = document.createElement('style');
  style.textContent = `
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      20%, 60% { transform: translateX(-5px); }
      40%, 80% { transform: translateX(5px); }
    }
  `;
  document.head.appendChild(style);

  // Add subtle parallax effect on scroll (mobile-friendly)
  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      window.requestAnimationFrame(() => {
        const scrolled = window.pageYOffset;
        const decorations = document.querySelectorAll('.lotus-decoration');
        decorations.forEach((dec, i) => {
          const speed = i === 0 ? 0.3 : 0.2;
          dec.style.transform = `translateY(${scrolled * speed}px)`;
        });
        ticking = false;
      });
      ticking = true;
    }
  });
});
JS_EOF

echo "✓ Created public/app.js"

# Create README.md
cat > README.md << 'README_EOF'
# 🧘 AAA - The Amazing Alternative to Awesome

A yoga teacher training app that provides mindful alternatives to saying "awesome" in class.

## Features

- **Random Awesomeness Button** - Get a quick single-word alternative
- **Contextual Cue Generator** - Enter a phrase and receive pose-specific feedback
- **AI-Powered** (optional) - Set your OpenAI API key for dynamic responses
- **Mobile-Friendly** - Designed for use on phones during prep

## Quick Start

```bash
# Install dependencies
npm install

# Start the server
npm start

# Visit http://localhost:12000
```

## Enable AI Mode

For dynamic, unlimited cue generation:

```bash
export OPENAI_API_KEY="your-key-here"
npm start
```

## Philosophy

This app helps yoga teachers move away from generic praise like "awesome" and "amazing" toward specific, instructive feedback that:

- Helps students understand what they're doing well
- Keeps students safe and engaged
- Provides meaningful guidance on alignment and form

---

Made with 💙 for yoga teacher training
README_EOF

echo "✓ Created README.md"

echo ""
echo "🎉 All files created successfully!"
echo ""
echo "Next steps:"
echo "  1. Run: npm install"
echo "  2. Run: npm start"
echo "  3. Visit: http://localhost:12000"
echo ""
echo "To push to GitHub:"
echo "  git add ."
echo "  git commit -m 'Initial commit: AAA yoga app'"
echo "  git push origin main"
echo ""
echo "Namaste! 🙏"
