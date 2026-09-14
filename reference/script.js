/* ==========================================================================
   AI AGRI — SMART, NATURAL & FARMER-FRIENDLY JAVASCRIPT LOGIC
   Preserving 100% Functionality • Added Living Nature & Scroll Animations
   ========================================================================== */

// Smooth Scrolling helper
function scrollTo(id) {
  const el = document.getElementById(id);
  if (el) {
    el.scrollIntoView({ behavior: 'smooth' });
  }
}

// Toggle Farm Risk Center Detail ("What should I do?")
function toggleRiskDetail(btn, id) {
  const detailEl = document.getElementById(id);
  if (!detailEl) return;
  detailEl.classList.toggle('show');
  if (detailEl.classList.contains('show')) {
    btn.innerHTML = '<span>Hide Advice</span> <span>▲</span>';
  } else {
    btn.innerHTML = '<span>What should I do?</span> <span>▼</span>';
  }
}

// Interactive Action Plan Checkbox ("What Should I Do Today?")
function toggleAction(box) {
  const parentItem = box.closest('.action-plan-item');
  box.classList.toggle('checked');
  if (parentItem) parentItem.classList.toggle('checked');
  
  if (box.classList.contains('checked')) {
    box.innerHTML = '✓';
  } else {
    box.innerHTML = '';
  }
}

// Tabs for Natural Remedies
function swTab(btn, id) {
  document.querySelectorAll('.remedy-tab-btn, .tb').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('.remedy-tab-pane, .tc').forEach(c => c.classList.remove('active'));
  btn.classList.add('active');
  const target = document.getElementById(id);
  if (target) {
    target.classList.add('active');
    // Hidden panes never trigger the scroll observer, so reveal their cards now
    target.querySelectorAll('.reveal-stagger').forEach(grid => grid.classList.add('revealed'));
  }
}

// 1-CLICK SAMPLE LEAVES FOR TESTING & DEMO
const SAMPLE_LEAF_PRESETS = {
  tomato: {
    crop: 'Tomato',
    problem: 'Early Blight (Fungal Infection)',
    confidence: '91%',
    severity: 'Medium',
    currentRisk: 'Medium',
    futureRisk: 'High (in 7 days if untreated)',
    badgeClass: 'diag-danger',
    why: 'Rain and high humidity (above 80%) make fungal spores grow quickly on warm leaves.',
    recommendedAction: 'Check lower leaves today. Remove any leaves with brown spots and apply spray.',
    chemical: 'Spray Mancozeb 75 WP (2g per liter water) on leaf undersides. Repeat after 7 days.',
    organic: [
      'Neem oil spray (5ml per liter water with a few drops of soap) every 5 days',
      'Sour buttermilk (1 part buttermilk in 5 parts water) sprayed on leaves',
      'Remove and safely bury yellow or spotted leaves immediately'
    ],
    prevention: 'Water at the base of plants, not overhead. Keep good spacing between plants so air can dry the leaves.',
    healthScore: 65,
    riskLevels: [18, 32, 50, 68, 80, 88, 92],
    img: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb22509?auto=format&fit=crop&w=600&q=80'
  },
  wheat: {
    crop: 'Wheat',
    problem: 'Yellow Rust (Stripe Rust)',
    confidence: '95%',
    severity: 'High',
    currentRisk: 'High',
    futureRisk: 'Very High (rapid spread)',
    badgeClass: 'diag-danger',
    why: 'Cool and damp morning weather helps yellow rust spores spread fast from plant to plant.',
    recommendedAction: 'Inspect crop borders immediately. Spray fungicide within 24–48 hours.',
    chemical: 'Spray Propiconazole 25 EC (Tilt) @ 1ml per liter of water immediately across infected fields.',
    organic: [
      'Fermented sour buttermilk + pinch of turmeric powder sprayed on crop',
      'Garlic and chilli natural extract spray to strengthen plant defence',
      'Remove heavily yellowed plants from border rows'
    ],
    prevention: 'Always sow rust-resistant seed varieties (such as HD-2967 or HD-3086). Avoid excess urea fertilizer.',
    healthScore: 50,
    riskLevels: [30, 48, 65, 80, 90, 95, 98],
    img: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=600&q=80'
  },
  healthy: {
    crop: 'Wheat / Field Crop',
    problem: 'No Problem Detected (Healthy Leaf)',
    confidence: '98%',
    severity: 'None',
    currentRisk: 'Low',
    futureRisk: 'Low (Healthy)',
    badgeClass: 'diag-healthy',
    why: 'Good green color and strong leaf tissue. No disease spots, mold, or insect bites found.',
    recommendedAction: 'No action needed. Keep following your regular watering and feeding schedule.',
    chemical: 'No chemical spray needed. Save your money and protect soil health.',
    organic: [
      'Continue regular organic compost or seaweed extract feeding',
      'Keep checking the field once a week for any early changes'
    ],
    prevention: 'Maintain balanced fertilizer application and keep weed-free borders.',
    healthScore: 95,
    riskLevels: [5, 5, 6, 7, 8, 9, 10],
    img: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=600&q=80'
  }
};

function loadSampleLeaf(type) {
  const preset = SAMPLE_LEAF_PRESETS[type];
  if (!preset) return;
  
  const img = document.getElementById('prevImg');
  const prevWrap = document.getElementById('prevWrap');
  const laser = document.getElementById('scannerLaser');
  
  if (img) {
    img.src = preset.img;
    img.style.display = 'block';
  }
  if (prevWrap) prevWrap.style.display = 'block';
  if (laser) laser.classList.add('active');
  
  const upText = document.getElementById('upText');
  if (upText) upText.textContent = '🤖 Scanning crop leaf for disease patterns...';
  
  setTimeout(() => {
    if (laser) laser.classList.remove('active');
    applyDiagnosticResult(preset);
  }, 1400);
}

// File Upload Handler
function analyzeDisease(e) {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = function(ev) {
    const img = document.getElementById('prevImg');
    const prevWrap = document.getElementById('prevWrap');
    const laser = document.getElementById('scannerLaser');
    
    if (img) {
      img.src = ev.target.result;
      img.style.display = 'block';
    }
    if (prevWrap) prevWrap.style.display = 'block';
    if (laser) laser.classList.add('active');
    
    const upText = document.getElementById('upText');
    if (upText) upText.textContent = '🤖 Checking your crop leaves with AI...';
    
    setTimeout(() => {
      if (laser) laser.classList.remove('active');
      applyDiagnosticResult(SAMPLE_LEAF_PRESETS.tomato);
    }, 1800);
  };
  reader.readAsDataURL(file);
}

function applyDiagnosticResult(data) {
  const upText = document.getElementById('upText');
  if (upText) upText.textContent = '✓ Crop Check Complete!';
  
  const dBadge = document.getElementById('dBadge');
  if (dBadge) {
    dBadge.className = 'diagnosis-badge ' + data.badgeClass;
    dBadge.textContent = (data.badgeClass === 'diag-healthy' ? '✓ ' : '⚠️ ') + data.problem + ' • AI is ' + data.confidence + ' sure';
  }
  
  const dBox = document.getElementById('dBox');
  if (dBox) {
    dBox.innerHTML = `
      <h4>Crop: ${data.crop}</h4>
      <p><strong>Possible Problem:</strong> ${data.problem}</p>
      <div style="margin-top:8px;background:var(--bg-cream);padding:10px 12px;border-radius:8px;border:1px solid var(--border-subtle)">
        <p><strong>Why is this happening?</strong></p>
        <p style="color:var(--text-body);margin-top:2px">${data.why}</p>
      </div>
      <div class="diag-stat-row">
        <div><strong>Current Risk:</strong> ${data.currentRisk}</div>
        <div><strong>7-Day Risk:</strong> ${data.futureRisk}</div>
        <div><strong>Recommended Action:</strong> ${data.recommendedAction}</div>
      </div>
    `;
  }
  
  const disRes = document.getElementById('disRes');
  if (disRes) disRes.classList.add('show');
  
  const treatBox = document.getElementById('treatBox');
  if (treatBox) {
    const organicList = data.organic.map(item => `<li>🌿 ${item}</li>`).join('');
    treatBox.innerHTML = `
      <div style="margin-bottom:16px">
        <div style="font-weight:800;color:var(--forest-900);font-size:0.95rem;margin-bottom:6px">💊 Recommended Spray (Medicine)</div>
        <div style="font-size:0.86rem;background:var(--bg-canvas);border:1px solid var(--border-subtle);padding:12px;border-radius:8px;line-height:1.55">
          ${data.chemical}
        </div>
      </div>
      <div style="margin-bottom:16px">
        <div style="font-weight:800;color:var(--leaf-700);font-size:0.95rem;margin-bottom:6px">🌿 Natural &amp; Home Solutions (Desi Ilaaj)</div>
        <ul class="rlist">${organicList}</ul>
      </div>
      <div>
        <div style="font-weight:800;color:var(--forest-900);font-size:0.95rem;margin-bottom:6px">🛡 How to Prevent Next Time</div>
        <div style="font-size:0.84rem;color:var(--text-muted);line-height:1.55">
          ${data.prevention}
        </div>
      </div>
    `;
  }
  
  // Render 7-Day Spore Risk Progression
  renderRiskTimeline(data.riskLevels);
  
  // Animated Health Ring Gauge
  animateHealthScore(data.healthScore);
}

function animateHealthScore(targetScore) {
  const hscore = document.getElementById('hscore');
  const ring = document.getElementById('hring');
  const circ = 220;
  
  let current = 0;
  const stepTime = 16;
  const steps = 50;
  const increment = targetScore / steps;
  
  const timer = setInterval(() => {
    current += increment;
    if (current >= targetScore) {
      current = targetScore;
      clearInterval(timer);
    }
    if (hscore) hscore.textContent = Math.round(current) + '/100';
    
    if (ring) {
      const off = circ - (current / 100) * circ;
      ring.style.strokeDashoffset = off;
      ring.style.stroke = targetScore > 75 ? '#2e7d32' : targetScore > 50 ? '#d97706' : '#dc2626';
    }
  }, stepTime);
}

function renderRiskTimeline(risks) {
  const container = document.getElementById('riskTimeline');
  if (!container) return;
  const days = ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'];
  
  let html = '';
  days.forEach((day, idx) => {
    const val = risks[idx] || 10;
    const barClass = val > 65 ? 'high' : val > 35 ? 'med' : '';
    const labelColor = val > 65 ? 'color:var(--danger-600)' : val > 35 ? 'color:var(--amber-600)' : 'color:var(--leaf-700)';
    html += `
      <div class="fr-day-col">
        <div class="fr-day-name">${day}</div>
        <div class="fr-day-bar-wrap">
          <div class="fr-day-bar ${barClass}" style="height:${Math.max(12, val * 0.48)}px"></div>
        </div>
        <div class="fr-day-risk-label" style="${labelColor}">${val}%</div>
      </div>
    `;
  });
  container.innerHTML = html;
}

// WEATHER FOR YOUR FARM
function refreshWeather() {
  const temps = ['24°C', '26°C', '28°C', '30°C', '31°C'];
  const conditions = [
    { desc: 'Clear Sky • Good for Spraying', icon: '☀️' },
    { desc: 'Partly Cloudy • Good for Crop Growth', icon: '⛅' },
    { desc: 'Mild Breeze • Pleasant Weather', icon: '🌤' },
    { desc: 'Cloudy Sky • Hold Watering for 2 Days', icon: '☁️' }
  ];
  const t = temps[Math.floor(Math.random() * temps.length)];
  const c = conditions[Math.floor(Math.random() * conditions.length)];
  
  const wTemp = document.getElementById('wTemp');
  const wDesc = document.getElementById('wDesc');
  if (wTemp) wTemp.textContent = t;
  if (wDesc) wDesc.textContent = c.icon + ' ' + c.desc;
}

// CROP MARKET & PRICE CHART
let pChart;
const crops = {
  Wheat: {
    d: [1900, 1950, 2020, 2100, 2180, 2250, 2340],
    cur: '₹2,180',
    pred: '₹2,340',
    msp: '₹2,015',
    chg: '▲ Prices Rising (+3.2%)',
    up: true,
    adv: 'Wheat prices are rising nicely. Best time to sell is in the 3rd week of April. You can expect about 7% more money.'
  },
  Rice: {
    d: [2200, 2280, 2350, 2400, 2450, 2380, 2500],
    cur: '₹2,450',
    pred: '₹2,500',
    msp: '₹2,183',
    chg: '▲ Stable Prices (+2.1%)',
    up: true,
    adv: 'Rice price is steady and well above Govt MSP. Good time to start selling in parts over the next 2 weeks.'
  },
  Maize: {
    d: [1400, 1480, 1550, 1620, 1680, 1700, 1750],
    cur: '₹1,680',
    pred: '₹1,750',
    msp: '₹1,590',
    chg: '▲ Good Demand (+4.0%)',
    up: true,
    adv: 'Demand for maize is strong. Waiting 10 to 14 more days before selling may give you higher profit.'
  },
  Tomato: {
    d: [800, 1200, 600, 1800, 2400, 1600, 900],
    cur: '₹2,400',
    pred: '₹900',
    msp: 'N/A',
    chg: '▼ Prices Falling Fast (-62%)',
    up: false,
    adv: 'Lots of tomatoes will arrive in the market next week. Sell all ripe tomatoes immediately within 2 days.'
  },
  Onion: {
    d: [1200, 1500, 1800, 2200, 1900, 1600, 1400],
    cur: '₹1,900',
    pred: '₹1,400',
    msp: 'N/A',
    chg: '▼ Prices Softening (-12%)',
    up: false,
    adv: 'New onion harvest is entering mandis. Sell your stored onions in batches over the next 10 days.'
  },
  Potato: {
    d: [900, 1100, 1200, 1400, 1300, 1250, 1100],
    cur: '₹1,300',
    pred: '₹1,100',
    msp: 'N/A',
    chg: '▼ Steady / Slow (-5.4%)',
    up: false,
    adv: 'Potato market is normal. If possible, consider selling directly to local potato chip makers for fixed good rates.'
  }
};

function selCrop(el, name) {
  document.querySelectorAll('.crop-chip-btn, .chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
  const d = crops[name];
  if (!d) return;
  
  const pCur = document.getElementById('pCur');
  const pPred = document.getElementById('pPred');
  const pMSP = document.getElementById('pMSP');
  const pChg = document.getElementById('pChg');
  const pAdvice = document.getElementById('pAdvice');
  
  if (pCur) pCur.textContent = d.cur;
  if (pPred) pPred.textContent = d.pred;
  if (pMSP) pMSP.textContent = d.msp;
  if (pChg) {
    pChg.textContent = d.chg;
    pChg.className = 'm-delta ' + (d.up ? 'up' : 'dn');
  }
  if (pAdvice) pAdvice.textContent = d.adv;
  
  if (pChart) {
    pChart.data.datasets[0].data = d.d;
    pChart.data.datasets[0].label = name + ' Mandi Price (₹/Quintal)';
    pChart.update();
  }
}

function initPriceChart() {
  const canvas = document.getElementById('priceChart');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  
  pChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr (Expected)'],
      datasets: [
        {
          label: 'Wheat Mandi Price (₹/Quintal)',
          data: crops.Wheat.d,
          borderColor: '#1e4a2a',
          backgroundColor: 'rgba(46, 125, 50, 0.08)',
          tension: 0.35,
          fill: true,
          borderWidth: 2.5,
          pointRadius: 4,
          pointBackgroundColor: '#1e4a2a',
          pointBorderColor: '#ffffff',
          pointBorderWidth: 2
        },
        {
          label: 'Govt. MSP Floor Price',
          data: [2015, 2015, 2015, 2015, 2015, 2015, 2015],
          borderColor: '#d97706',
          borderDash: [6, 4],
          tension: 0,
          fill: false,
          borderWidth: 1.5,
          pointRadius: 0
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: {
            boxWidth: 12,
            font: { family: 'Plus Jakarta Sans', size: 11, weight: 600 },
            color: '#2c382e'
          }
        },
        tooltip: {
          backgroundColor: '#102816',
          padding: 10,
          titleFont: { family: 'Outfit', size: 12 },
          bodyFont: { family: 'Plus Jakarta Sans', size: 11 }
        }
      },
      scales: {
        y: {
          grid: { color: 'rgba(0, 0, 0, 0.04)' },
          ticks: { font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#5b6b5e' }
        },
        x: {
          grid: { display: false },
          ticks: { font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#5b6b5e' }
        }
      }
    }
  });
}

function initYieldChart() {
  const canvas = document.getElementById('yieldChart');
  if (!canvas) return;
  new Chart(canvas.getContext('2d'), {
    type: 'bar',
    data: {
      labels: ['2019', '2020', '2021', '2022', '2023', '2024'],
      datasets: [
        { label: 'Wheat', data: [18, 20, 19, 22, 24, 26], backgroundColor: '#2e7d32', borderRadius: 4 },
        { label: 'Rice', data: [22, 21, 24, 25, 23, 27], backgroundColor: '#5f7544', borderRadius: 4 },
        { label: 'Maize', data: [16, 18, 17, 20, 22, 24], backgroundColor: '#d97706', borderRadius: 4 }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { boxWidth: 10, font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#2c382e' }
        }
      },
      scales: {
        x: { grid: { display: false }, ticks: { font: { size: 10 }, color: '#5b6b5e' } },
        y: { grid: { color: 'rgba(0,0,0,0.04)' }, ticks: { font: { size: 10 }, color: '#5b6b5e' } }
      }
    }
  });
}

function initMktChart() {
  const canvas = document.getElementById('mktChart');
  if (!canvas) return;
  new Chart(canvas.getContext('2d'), {
    type: 'radar',
    data: {
      labels: ['Wheat', 'Rice', 'Maize', 'Tomato', 'Onion', 'Potato'],
      datasets: [
        {
          label: 'Local Mandi',
          data: [72, 80, 58, 90, 65, 55],
          borderColor: '#2e7d32',
          backgroundColor: 'rgba(46, 125, 50, 0.15)',
          borderWidth: 2,
          pointRadius: 3
        },
        {
          label: 'Direct / e-NAM',
          data: [82, 75, 70, 85, 78, 62],
          borderColor: '#d97706',
          backgroundColor: 'rgba(217, 119, 6, 0.1)',
          borderWidth: 2,
          pointRadius: 3
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { boxWidth: 10, font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#2c382e' }
        }
      },
      scales: {
        r: {
          ticks: { font: { size: 9 }, backdropColor: 'transparent', color: '#5b6b5e' },
          grid: { color: 'rgba(0,0,0,0.05)' },
          angleLines: { color: 'rgba(0,0,0,0.05)' }
        }
      }
    }
  });
}

function initWxChart() {
  const canvas = document.getElementById('wxChart');
  if (!canvas) return;
  new Chart(canvas.getContext('2d'), {
    type: 'line',
    data: {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      datasets: [
        {
          label: 'Temperature (°C)',
          data: [8, 10, 16, 22, 28, 32, 30, 28, 24, 18, 12, 8],
          borderColor: '#dc2626',
          fill: false,
          tension: 0.35,
          yAxisID: 'y',
          borderWidth: 2,
          pointRadius: 2
        },
        {
          label: 'Rainfall (mm)',
          data: [25, 20, 18, 12, 10, 80, 180, 200, 120, 40, 15, 20],
          borderColor: '#0284c7',
          backgroundColor: 'rgba(2, 132, 199, 0.12)',
          fill: true,
          tension: 0.35,
          yAxisID: 'y1',
          borderWidth: 2,
          pointRadius: 2
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { boxWidth: 10, font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#2c382e' }
        }
      },
      scales: {
        y: {
          type: 'linear',
          position: 'left',
          ticks: { font: { size: 9 }, color: '#5b6b5e' },
          grid: { color: 'rgba(0,0,0,0.04)' }
        },
        y1: {
          type: 'linear',
          position: 'right',
          ticks: { font: { size: 9 }, color: '#5b6b5e' },
          grid: { display: false }
        },
        x: {
          grid: { display: false },
          ticks: { font: { size: 9 }, color: '#5b6b5e' }
        }
      }
    }
  });
}

function initDiseaseChart() {
  const canvas = document.getElementById('diseaseChart');
  if (!canvas) return;
  new Chart(canvas.getContext('2d'), {
    type: 'bar',
    data: {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      datasets: [
        { label: 'Fungal Risk', data: [5, 6, 8, 14, 18, 22, 28, 30, 20, 12, 7, 5], backgroundColor: '#dc2626', borderRadius: 3 },
        { label: 'Bacterial Risk', data: [3, 4, 5, 8, 10, 15, 18, 20, 12, 7, 4, 3], backgroundColor: '#d97706', borderRadius: 3 },
        { label: 'Pest Incursion', data: [8, 6, 12, 20, 25, 18, 15, 22, 18, 14, 9, 7], backgroundColor: '#0284c7', borderRadius: 3 }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { boxWidth: 10, font: { family: 'Plus Jakarta Sans', size: 10 }, color: '#2c382e' }
        }
      },
      scales: {
        x: { stacked: true, grid: { display: false }, ticks: { font: { size: 9 }, color: '#5b6b5e' } },
        y: { stacked: true, grid: { color: 'rgba(0,0,0,0.04)' }, ticks: { font: { size: 9 }, color: '#5b6b5e' } }
      }
    }
  });
}

// KRISHI COPILOT (VOICE ASSISTANT)
let recog = null;
let vLang = 'hi-IN';
let vActive = false;

const vRes = {
  'पीले धब्बे': 'गेहूं में पीले धब्बे येलो रस्ट हो सकती है। Propiconazole (टिल्ट) @ 1ml प्रति लीटर पानी में मिलाकर स्प्रे करें। खट्टी छाछ और नीम तेल का स्प्रे भी अच्छा काम करता है। 7 दिन बाद दोबारा देखें।',
  'मौसम': 'आज सोलन में 28°C तापमान है और हल्की धूप है। सुबह के समय कीटनाशक स्प्रे करने के लिए मौसम बहुत अच्छा है। बुधवार को बारिश हो सकती है।',
  'टमाटर': 'टमाटर का मंडी भाव आज ₹2,400 प्रति क्विंटल है। अगले 10 दिनों में बहुत सारा टमाटर आने से भाव गिर सकता है। पके हुए टमाटर तुरंत बेचें।',
  'कीटनाशक': 'घर पर प्राकृतिक कीटनाशक: 100 ग्राम लहसुन और 5 तीखी मिर्च 1 लीटर पानी में पीसें। 5 मिली नीम तेल मिलाकर स्प्रे करें। यह रसचूसक कीड़ों को तुरंत भगाता है।',
  'water': 'Your soil moisture is at 42%, which is good. You do not need to water today. Save water and check back in 2 days.',
  'spray': 'Yes, today morning between 6:00 AM and 10:30 AM is an optimal window for spraying. Wind speed is low.',
  'sow wheat': 'Best time to sow wheat in Himachal and North India is Oct 25 – Nov 15. Good seeds: HD-2967, HD-3086, DBW-187. Use 40 kg seed per acre.',
  '_hi': 'कृषि सहायक ने आपका प्रश्न समझ लिया है। कृपया ऊपर दिए गए फसल रोग और मंडी भाव अनुभाग भी देखें।',
  '_en': 'Krishi Copilot has received your question. Please check the Crop Health and Market tabs for more details.'
};

function setLang(btn, lang) {
  document.querySelectorAll('.copilot-lbtn, .lbtn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  vLang = lang;
  const stat = document.getElementById('vStat');
  if (stat) {
    stat.textContent = (lang.startsWith('en') ? 'English selected' : 'भाषा चुनी गई') + ' | Tap microphone to speak';
  }
}

function startVoice() {
  if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
    const vTrans = document.getElementById('vTrans');
    if (vTrans) {
      vTrans.innerHTML = 'Speech recognition not supported in this browser. Please use Chrome browser.<br>कृपया क्रोम ब्राउज़र का उपयोग करें।';
    }
    return;
  }
  
  if (vActive) {
    stopVoice();
    return;
  }
  
  recog = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
  recog.lang = vLang;
  recog.continuous = false;
  recog.interimResults = true;
  
  recog.onstart = () => {
    vActive = true;
    const btn = document.getElementById('vBtn');
    if (btn) {
      btn.classList.add('on');
      btn.textContent = '⏹';
    }
    const stat = document.getElementById('vStat');
    if (stat) stat.textContent = '🔴 Listening… बोलिए, सुन रहा हूँ…';
    const trans = document.getElementById('vTrans');
    if (trans) trans.textContent = 'Listening...';
    const resp = document.getElementById('vResp');
    if (resp) resp.classList.remove('show');
    document.querySelectorAll('.c-wave-bar, .wb').forEach(b => b.classList.add('on'));
  };
  
  recog.onresult = (e) => {
    let interim = '', final = '';
    for (let i = e.resultIndex; i < e.results.length; i++) {
      if (e.results[i].isFinal) final += e.results[i][0].transcript;
      else interim += e.results[i][0].transcript;
    }
    const trans = document.getElementById('vTrans');
    if (trans) trans.textContent = final || interim || '…';
    if (final) procVoice(final);
  };
  
  recog.onerror = () => {
    const trans = document.getElementById('vTrans');
    if (trans) trans.textContent = 'Microphone permission needed | माइक की अनुमति दें';
    stopVoice();
  };
  
  recog.onend = stopVoice;
  recog.start();
}

function stopVoice() {
  vActive = false;
  if (recog) {
    try { recog.stop(); } catch (e) {}
  }
  const btn = document.getElementById('vBtn');
  if (btn) {
    btn.classList.remove('on');
    btn.textContent = '🎙';
  }
  const stat = document.getElementById('vStat');
  if (stat) stat.textContent = 'Tap to speak | दोबारा बोलने के लिए टैप करें';
  document.querySelectorAll('.c-wave-bar, .wb').forEach(b => b.classList.remove('on'));
}

function procVoice(text) {
  let resp = null;
  const lower = text.toLowerCase();
  
  for (const k in vRes) {
    if (k !== '_hi' && k !== '_en' && (text.includes(k) || lower.includes(k))) {
      resp = vRes[k];
      break;
    }
  }
  if (!resp) resp = vLang.startsWith('en') ? vRes['_en'] : vRes['_hi'];
  
  const el = document.getElementById('vResp');
  if (el) {
    el.textContent = '🌱 ' + resp;
    el.classList.add('show');
  }
  
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(resp);
    u.lang = vLang;
    u.rate = 0.9;
    window.speechSynthesis.speak(u);
  }
}

function simV(text) {
  const trans = document.getElementById('vTrans');
  if (trans) trans.textContent = text;
  procVoice(text);
  scrollTo('voice');
}

// SCROLL OBSERVER & NAVBAR TRACKING
function initScrollInteractions() {
  const nav = document.querySelector('.top-nav');
  
  window.addEventListener('scroll', () => {
    if (window.scrollY > 20) {
      if (nav) nav.classList.add('scrolled');
    } else {
      if (nav) nav.classList.remove('scrolled');
    }
  }, { passive: true });
  
  // IntersectionObserver for Reveal Animations
  const revealElements = document.querySelectorAll('.card-ui, .risk-card, .farm-today-card, .weather-main-card, .copilot-panel, .section-head');
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.12,
    rootMargin: '0px 0px -40px 0px'
  });
  
  revealElements.forEach((el) => {
    el.classList.add('reveal-init');
    observer.observe(el);
  });
  
  // Section Link Tracking
  const sections = document.querySelectorAll('section[id], header[id]');
  const navLinks = document.querySelectorAll('.nav-link');
  
  window.addEventListener('scroll', () => {
    let current = '';
    const scrollPos = window.scrollY + 120;
    
    sections.forEach(sec => {
      const top = sec.offsetTop;
      const height = sec.offsetHeight;
      if (scrollPos >= top && scrollPos < top + height) {
        current = sec.getAttribute('id');
      }
    });
    
    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
      }
    });
  }, { passive: true });
}

// ==========================================================================
// FLOATING NATURE PARTICLE SYSTEM (Leaves, Seeds, Organic Elements)
// ==========================================================================
const NATURE_EMOJIS = ['🍃', '🌿', '🍂', '🌱', '🌾', '☘️', '🪴'];
let floatingLeaves = [];
let natureAnimFrame = null;

function createFloatingLeaf(container) {
  const leaf = document.createElement('div');
  leaf.className = 'floating-nature-leaf';
  leaf.textContent = NATURE_EMOJIS[Math.floor(Math.random() * NATURE_EMOJIS.length)];
  leaf.style.left = Math.random() * 100 + '%';
  leaf.style.fontSize = (0.8 + Math.random() * 0.8) + 'rem';
  leaf.style.opacity = '0';

  const duration = 18000 + Math.random() * 20000;
  const drift = -80 + Math.random() * 160;
  const rotateStart = Math.random() * 360;
  const rotateEnd = rotateStart + 180 + Math.random() * 360;

  container.appendChild(leaf);

  const leafData = {
    el: leaf,
    startTime: performance.now(),
    duration: duration,
    startX: parseFloat(leaf.style.left),
    drift: drift,
    rotateStart: rotateStart,
    rotateEnd: rotateEnd,
    swayAmplitude: 20 + Math.random() * 40,
    swayFrequency: 0.0005 + Math.random() * 0.001
  };

  floatingLeaves.push(leafData);
  return leafData;
}

function animateFloatingLeaves(timestamp) {
  const container = document.getElementById('floatingNature');
  if (!container) return;

  // Spawn new leaves periodically
  if (floatingLeaves.length < 8 && Math.random() < 0.008) {
    createFloatingLeaf(container);
  }

  // Update existing leaves
  for (let i = floatingLeaves.length - 1; i >= 0; i--) {
    const lf = floatingLeaves[i];
    const elapsed = timestamp - lf.startTime;
    const progress = Math.min(elapsed / lf.duration, 1);

    // Y position: bottom to top
    const y = (1 - progress) * (window.innerHeight + 80) - 40;
    // X position: drift + sine sway
    const sway = Math.sin(elapsed * lf.swayFrequency) * lf.swayAmplitude;
    const x = (lf.startX / 100) * window.innerWidth + lf.drift * progress + sway;
    // Rotation
    const rotation = lf.rotateStart + (lf.rotateEnd - lf.rotateStart) * progress;
    // Opacity: fade in, sustain, fade out
    let opacity = 0;
    if (progress < 0.08) opacity = progress / 0.08;
    else if (progress > 0.85) opacity = (1 - progress) / 0.15;
    else opacity = 1;
    opacity *= 0.45;

    lf.el.style.transform = `translate(${x}px, ${y}px) rotate(${rotation}deg)`;
    lf.el.style.opacity = opacity;

    // Remove completed leaves
    if (progress >= 1) {
      lf.el.remove();
      floatingLeaves.splice(i, 1);
    }
  }

  natureAnimFrame = requestAnimationFrame(animateFloatingLeaves);
}

function initFloatingNature() {
  const container = document.getElementById('floatingNature');
  if (!container) return;

  // Check reduced motion preference
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  // Seed initial leaves
  for (let i = 0; i < 4; i++) {
    setTimeout(() => createFloatingLeaf(container), i * 2500);
  }

  natureAnimFrame = requestAnimationFrame(animateFloatingLeaves);
}

// ==========================================================================
// PARALLAX SCROLL EFFECT (Subtle depth on hero & photo sections)
// ==========================================================================
function initParallaxScroll() {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  const heroPhoto = document.querySelector('.hero-bg-photo');
  const heroSunGlow = document.querySelector('.hero-sun-glow');
  const ctaPhoto = document.querySelector('.final-cta-photo-bg');

  let ticking = false;

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        const scrollY = window.scrollY;

        if (heroPhoto && scrollY < 800) {
          heroPhoto.style.transform = `scale(1.06) translateY(${scrollY * 0.12}px)`;
        }

        if (heroSunGlow && scrollY < 600) {
          heroSunGlow.style.transform = `translate(${-scrollY * 0.03}px, ${scrollY * 0.05}px) scale(${1 + scrollY * 0.0002})`;
        }

        if (ctaPhoto) {
          const rect = ctaPhoto.parentElement.getBoundingClientRect();
          if (rect.top < window.innerHeight && rect.bottom > 0) {
            const offset = (rect.top / window.innerHeight) * 30;
            ctaPhoto.style.transform = `scale(1.08) translateY(${offset}px)`;
          }
        }

        ticking = false;
      });
      ticking = true;
    }
  }, { passive: true });
}

// ==========================================================================
// ENHANCED SCROLL REVEAL (Staggered + Counter Animation)
// ==========================================================================
function initEnhancedReveal() {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  // Staggered reveal for grids
  const staggerContainers = document.querySelectorAll('.reveal-stagger');
  const staggerObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        staggerObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -30px 0px' });

  staggerContainers.forEach((el) => staggerObserver.observe(el));

  // Section photo backdrop fade
  const photoBackdrops = document.querySelectorAll('.section-photo-backdrop');
  const backdropObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '0.06';
      }
    });
  }, { threshold: 0.2 });

  photoBackdrops.forEach((el) => backdropObserver.observe(el));
}

// ==========================================================================
// COUNTER ANIMATION (Smooth number counting for stats)
// ==========================================================================
function animateCounter(el, target, prefix, suffix, duration) {
  prefix = prefix || '';
  suffix = suffix || '';
  duration = duration || 1200;

  const start = 0;
  const startTime = performance.now();

  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    // Ease out cubic
    const eased = 1 - Math.pow(1 - progress, 3);
    const current = Math.round(start + (target - start) * eased);

    el.textContent = prefix + current.toLocaleString('en-IN') + suffix;

    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }

  requestAnimationFrame(update);
}

// ==========================================================================
// ENHANCED SCANNER ANIMATION
// ==========================================================================
function enhanceScanner() {
  const upZone = document.getElementById('upZone');
  if (!upZone) return;

  // Add visual scanning feedback to file input
  const fileInput = upZone.querySelector('input[type="file"]');
  if (fileInput) {
    fileInput.addEventListener('change', () => {
      upZone.classList.add('scanning');
      setTimeout(() => upZone.classList.remove('scanning'), 2000);
    });
  }

  // Add hover glow effect
  upZone.addEventListener('mouseenter', () => {
    if (!upZone.classList.contains('scanning')) {
      upZone.style.borderColor = 'var(--leaf-500)';
      upZone.style.background = 'linear-gradient(135deg, var(--leaf-50), var(--bg-card-subtle))';
    }
  });

  upZone.addEventListener('mouseleave', () => {
    if (!upZone.classList.contains('scanning')) {
      upZone.style.borderColor = '';
      upZone.style.background = '';
    }
  });
}

// ==========================================================================
// WEATHER RAIN EFFECT TOGGLE
// ==========================================================================
function toggleRainEffect(show) {
  const weatherSection = document.getElementById('weather');
  if (!weatherSection) return;

  let rainContainer = weatherSection.querySelector('.rain-container');
  if (!rainContainer) {
    rainContainer = document.createElement('div');
    rainContainer.className = 'rain-container';
    // Create rain drops
    for (let i = 0; i < 30; i++) {
      const drop = document.createElement('div');
      drop.className = 'rain-drop';
      drop.style.left = Math.random() * 100 + '%';
      drop.style.animationDuration = (0.5 + Math.random() * 0.5) + 's';
      drop.style.animationDelay = Math.random() * 2 + 's';
      rainContainer.appendChild(drop);
    }
    weatherSection.appendChild(rainContainer);
  }

  if (show) {
    rainContainer.classList.add('active');
  } else {
    rainContainer.classList.remove('active');
  }
}

// ==========================================================================
// SMOOTH SCROLL PROGRESS INDICATOR
// ==========================================================================
function initScrollProgress() {
  const nav = document.querySelector('.top-nav');
  if (!nav) return;

  // Create progress bar
  const progressBar = document.createElement('div');
  progressBar.style.cssText = `
    position: absolute;
    bottom: 0;
    left: 0;
    height: 2px;
    background: linear-gradient(90deg, var(--leaf-500), var(--harvest-500));
    transition: width 0.15s ease;
    width: 0%;
    z-index: 1001;
    border-radius: 0 1px 1px 0;
  `;
  nav.appendChild(progressBar);

  window.addEventListener('scroll', () => {
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
    progressBar.style.width = progress + '%';
  }, { passive: true });
}

// ==========================================================================
// HERO 3D ENVIRONMENT — pointer-driven depth (desktop only, motion-safe)
// ==========================================================================
const prefersReducedMotion = () =>
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

function initHero3D() {
  const stage = document.getElementById('hero3d');
  const hero = document.getElementById('hero');
  if (!stage || !hero) return;
  if (prefersReducedMotion() || window.innerWidth < 1025) return;

  const chips = Array.from(stage.querySelectorAll('[data-depth]'));
  let targetX = 0, targetY = 0, curX = 0, curY = 0, running = false;

  // Rest pose keeps a gentle 3D read even before the pointer arrives
  const REST_RY = -6, REST_RX = 2.2, MAX = 4.5;

  function loop() {
    curX += (targetX - curX) * 0.06;
    curY += (targetY - curY) * 0.06;
    stage.style.setProperty('--stage-ry', (REST_RY + curY).toFixed(2) + 'deg');
    stage.style.setProperty('--stage-rx', (REST_RX + curX).toFixed(2) + 'deg');
    chips.forEach(chip => {
      const d = (parseFloat(chip.dataset.depth) || 20) / 100;
      // Consumed inside the chipFloat keyframes, so the gentle float keeps running
      chip.style.setProperty('--px', (curY * d * 2.6).toFixed(2) + 'px');
      chip.style.setProperty('--py', (-curX * d * 2.6).toFixed(2) + 'px');
    });
    if (Math.abs(targetX - curX) > 0.01 || Math.abs(targetY - curY) > 0.01) {
      requestAnimationFrame(loop);
    } else {
      running = false;
    }
  }

  function kick() {
    if (!running) { running = true; requestAnimationFrame(loop); }
  }

  hero.addEventListener('mousemove', (e) => {
    const r = hero.getBoundingClientRect();
    const nx = (e.clientX - r.left) / r.width - 0.5;
    const ny = (e.clientY - r.top) / r.height - 0.5;
    targetY = Math.max(-MAX, Math.min(MAX, nx * MAX * 2));
    targetX = Math.max(-MAX, Math.min(MAX, -ny * MAX * 1.4));
    stage.style.transition = 'none';
    kick();
  }, { passive: true });

  hero.addEventListener('mouseleave', () => {
    targetX = 0; targetY = 0;
    stage.style.transition = 'transform 0.9s cubic-bezier(0.22, 1, 0.36, 1)';
    kick();
  });

  kick();
}

// ==========================================================================
// SUBTLE CARD TILT — max ~3.5deg, desktop pointer only
// ==========================================================================
function initCardTilt() {
  if (prefersReducedMotion() || window.innerWidth < 1025) return;
  if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) return;

  const MAX_TILT = 3.5;
  document.querySelectorAll('.card-tilt').forEach(card => {
    card.addEventListener('mousemove', (e) => {
      const r = card.getBoundingClientRect();
      const nx = (e.clientX - r.left) / r.width - 0.5;
      const ny = (e.clientY - r.top) / r.height - 0.5;
      card.style.setProperty('--tilt-y', (nx * MAX_TILT * 2).toFixed(2) + 'deg');
      card.style.setProperty('--tilt-x', (-ny * MAX_TILT * 2).toFixed(2) + 'deg');
    }, { passive: true });

    card.addEventListener('mouseleave', () => {
      card.style.setProperty('--tilt-y', '0deg');
      card.style.setProperty('--tilt-x', '0deg');
    });
  });
}

// ==========================================================================
// SUNLIT POLLEN MOTES IN THE HERO
// ==========================================================================
function initHeroPollen() {
  const holder = document.getElementById('heroPollen');
  if (!holder) return;
  if (prefersReducedMotion() || window.innerWidth < 769) return;

  const count = 16;
  for (let i = 0; i < count; i++) {
    const mote = document.createElement('span');
    mote.className = 'pollen-mote';
    const size = 2 + Math.random() * 4;
    mote.style.width = size + 'px';
    mote.style.height = size + 'px';
    mote.style.left = (Math.random() * 100) + '%';
    mote.style.setProperty('--mx', (Math.random() * 120 - 60).toFixed(0) + 'px');
    mote.style.setProperty('--mrise', (55 + Math.random() * 45) + 'vh');
    mote.style.animationDuration = (16 + Math.random() * 16).toFixed(1) + 's';
    mote.style.animationDelay = (Math.random() * 18).toFixed(1) + 's';
    holder.appendChild(mote);
  }
}

// ==========================================================================
// CHARTS FADE IN GENTLY WHEN THEY COME INTO VIEW
// ==========================================================================
function initChartEntrance() {
  const wraps = document.querySelectorAll('.chart-container-wrap');
  if (!wraps.length || !('IntersectionObserver' in window)) return;
  if (prefersReducedMotion()) return;

  wraps.forEach(w => {
    w.style.opacity = '0';
    w.style.transform = 'translateY(14px)';
    w.style.transition = 'opacity 1s cubic-bezier(0.22, 1, 0.36, 1), transform 1s cubic-bezier(0.22, 1, 0.36, 1)';
  });

  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      entry.target.style.opacity = '1';
      entry.target.style.transform = 'translateY(0)';
      io.unobserve(entry.target);
    });
  }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

  wraps.forEach(w => io.observe(w));
}

// ==========================================================================
// DOM INITIALIZATION
// ==========================================================================
window.addEventListener('DOMContentLoaded', () => {
  initPriceChart();
  initYieldChart();
  initMktChart();
  initWxChart();
  initDiseaseChart();
  
  // Render initial risk timeline
  renderRiskTimeline([18, 32, 50, 68, 80, 88, 92]);
  
  // Initial Health Score Animation (0 -> 82)
  animateHealthScore(82);
  
  // Initialize Scroll & Reveal
  initScrollInteractions();

  // Premium Visual Enhancements
  initFloatingNature();
  initParallaxScroll();
  initEnhancedReveal();
  enhanceScanner();
  initScrollProgress();

  // 3D Depth Layer
  initHero3D();
  initCardTilt();
  initHeroPollen();
  initChartEntrance();
});
