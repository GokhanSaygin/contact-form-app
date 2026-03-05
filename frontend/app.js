const API_URL = 'https://5tis82cuq7.execute-api.us-east-1.amazonaws.com/dev';

// ─── Contact Form Submit ───────────────────────────────
const form = document.getElementById('contactForm');

if (form) {
  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const btn        = document.getElementById('submitBtn');
    const successMsg = document.getElementById('successMsg');
    const errorMsg   = document.getElementById('errorMsg');

    const name    = document.getElementById('name').value;
    const email   = document.getElementById('email').value;
    const message = document.getElementById('message').value;

    btn.disabled    = true;
    btn.textContent = 'Sending...';
    successMsg.style.display = 'none';
    errorMsg.style.display   = 'none';

    try {
      const res = await fetch(`${API_URL}/submit`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ name, email, message })
      });

      if (res.ok) {
        successMsg.style.display = 'block';
        form.reset();
      } else {
        errorMsg.style.display = 'block';
      }
    } catch (err) {
      errorMsg.style.display = 'block';
    } finally {
      btn.disabled    = false;
      btn.textContent = 'Send Message';
    }
  });
}

// ─── Admin: Load Messages ──────────────────────────────
async function loadMessages() {
  const container = document.getElementById('messages');
  if (!container) return;

  try {
    const res   = await fetch(`${API_URL}/contacts`);
    const items = await res.json();

    if (items.length === 0) {
      container.innerHTML = '<p>No messages yet.</p>';
      return;
    }

    container.innerHTML = items.map(item => `
      <div class="message-card">
        <h3>${item.name}</h3>
        <p>📧 ${item.email}</p>
        <p>💬 ${item.message}</p>
        <small>🕐 ${new Date(item.createdAt).toLocaleString()}</small>
      </div>
    `).join('');

  } catch (err) {
    container.innerHTML = '<p>Failed to load messages.</p>';
  }
}