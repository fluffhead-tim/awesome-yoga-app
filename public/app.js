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
