# GRIDWISE. 🔋 — Platform for Intelligent Energy Management

**Status**: ✅ Active Development | **Last Updated**: September 2, 2026

A comprehensive, multiplataform intelligent energy management platform with real-time monitoring, AI-powered recommendations, and IoT device integration.

---

## 📋 Quick Links

- 🌐 [Live Demo](#) (Coming soon)
- 📖 [Documentation](./docs/README.md)
- 🐛 [Report Bug](../../issues/new?template=bug_report.md)
- ✨ [Request Feature](../../issues/new)
- 🤝 [Contributing Guide](./CONTRIBUTING.md)
- 🔐 [Security Policy](./SECURITY.md)

---

## ✨ Features

### 📊 Real-Time Monitoring
- Live energy consumption dashboard with interactive charts
- Device-by-device power tracking
- Historical data visualization and trends
- Real-time updates via WebSocket (Socket.IO)

### 🤖 AI-Powered Assistant
- GridWise Assistant powered by Google Gemini AI
- Natural language interaction for energy insights
- Personalized recommendations based on consumption patterns
- Automated anomaly detection

### ⚡ Smart Alerts & Automation
- Threshold-based alerts for consumption spikes
- Customizable notification rules
- Automated device scheduling
- Usage pattern learning and optimization

### 🌐 Multi-Platform Support
- Native iOS & Android apps (Flutter)
- Responsive web interface
- Cross-platform data synchronization
- Offline-first architecture

### 🔌 IoT Integration
- MQTT-based device communication
- Support for multiple sensor types
- Real-time device status monitoring
- Firmware update management

### 📈 Analytics & Reporting
- Consumption trends and forecasting
- Energy cost estimation
- Peak usage identification
- Customizable report generation

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Flutter    │  │  Web Browser │  │   Desktop    │      │
│  │  (iOS/And)   │  │  (React/Vue) │  │  (Electron)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬─────────────────────────────────────┘
                         │
                    Socket.IO (Real-time)
                         │
┌────────────────────────┬─────────────────────────────────────┐
│                  Backend API Layer                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Node.js + Express.js                        │   │
│  │  ┌─────────────┐  ┌──────────┐  ┌──────────────┐   │   │
│  │  │ Auth Routes │  │API Routes│  │ AI Service  │   │   │
│  │  └─────────────┘  └──────────┘  └──────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────┬─────────────────────┬──────────────────────────┘
              │                     │
      Firebase Admin SDK    Google Gemini API
              │                     │
┌─────────────┴─────────────────────┴──────────────────────────┐
│                  Data & AI Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Firestore   │  │ Cloud Gemini │  │  Analytics  │       │
│  │  (NoSQL DB)  │  │  (AI Engine) │  │   Engine    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────┬──────────────────────────────────────────────────┘
              │
              │ Real-time Data Sync
              │
┌─────────────┴────────────────────────────────────────────────┐
│                   IoT Device Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Smart      │  │   Energy     │  │   Climate    │       │
│  │   Meters     │  │   Sensors    │  │   Sensors    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
              ▲
              │ MQTT Protocol
              │
         ┌────────────┐
         │ MQTT Broker│
         └────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x | Cross-platform mobile & web |
| **Frontend** | fl_chart | Interactive charts |
| **Frontend** | Firebase SDK | Client-side integration |
| **Backend** | Node.js 16+ | Runtime environment |
| **Backend** | Express.js | REST API framework |
| **Backend** | Socket.IO | Real-time bidirectional communication |
| **Database** | Firestore | NoSQL real-time database |
| **Authentication** | Firebase Auth | Email/Password + OAuth 2.0 |
| **AI** | Google Gemini API | Natural language processing |
| **IoT** | MQTT | Device communication protocol |
| **DevOps** | Docker | Containerization |
| **Testing** | Jest | Unit & integration tests |

---

## 🚀 Getting Started

### Prerequisites

- Node.js 16 or higher
- Flutter 3.0 or higher
- Firebase account with Firestore database
- Google Cloud Gemini API key
- MQTT broker access (HiveMQ or Mosquitto)

### Installation

#### Backend Setup

```bash
# Clone repository
git clone https://github.com/fredy200104/GRIDWISE.git
cd GRIDWISE/gridwise-backend

# Install dependencies
npm install

# Create .env file (see .env.example)
cp .env.example .env
# Edit .env with your credentials

# Initialize Firestore (if needed)
npm run init:firebase

# Start development server
npm run dev

# Server runs on http://localhost:3000
```

#### Frontend Setup (Flutter)

```bash
# Navigate to Flutter app
cd ../lib

# Get dependencies
flutter pub get

# Configure Firebase
flutter pub run flutter_config:setup

# Run on device/emulator
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

#### IoT Device Setup

```bash
# Configure MQTT connection on devices
MQTT_BROKER=your-broker-url
MQTT_PORT=1883
MQTT_USERNAME=your-username
MQTT_PASSWORD=your-password

# Deploy firmware (see docs/IoT_SETUP.md)
```

---

## 📖 Documentation

- **[Architecture Guide](./docs/ARCHITECTURE.md)** — System design and components
- **[API Reference](./docs/API.md)** — Complete REST API documentation
- **[Security Guide](./docs/SECURITY.md)** — Security implementation details
- **[Deployment Guide](./docs/DEPLOYMENT.md)** — Production deployment
- **[IoT Setup](./docs/IoT_SETUP.md)** — Device configuration
- **[Contributing](./CONTRIBUTING.md)** — How to contribute
- **[Security Policy](./SECURITY.md)** — Vulnerability reporting

---

## 🧪 Testing

```bash
# Backend tests
cd gridwise-backend
npm test

# With coverage
npm run test:coverage

# Watch mode
npm run test:watch

# Specific test file
npm test -- tests/auth.test.js
```

### Running Tests Locally

1. **Unit Tests** (fastest, test individual functions)
   ```bash
   npm run test:unit
   ```

2. **Integration Tests** (test components working together)
   ```bash
   npm run test:integration
   ```

3. **E2E Tests** (test full user workflows)
   ```bash
   npm run test:e2e
   ```

---

## 🔐 Security

### Security Features Implemented

✅ **Authentication & Authorization**
- Firebase Authentication (Email/Password)
- Google OAuth 2.0 integration
- JWT token-based session management
- Role-based access control (RBAC)

✅ **Data Protection**
- Firestore security rules (row-level security)
- End-to-end encryption for sensitive data
- Password hashing with bcrypt
- Secrets management via environment variables

✅ **Network Security**
- HTTPS/TLS for all communications
- MQTT over TLS for device communication
- CORS properly configured
- Rate limiting on API endpoints

✅ **API Security**
- Input validation on all endpoints
- SQL injection prevention (NoSQL but still validated)
- CSRF token protection
- XSS prevention via output encoding

### Reporting Security Issues

**⚠️ DO NOT create public issues for security vulnerabilities.**

Please report privately to: **fandinof302@gmail.com**

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

See [SECURITY.md](./SECURITY.md) for full details.

---

## 🐛 Troubleshooting

### Common Issues

**Problem: Firebase connection fails**
```bash
Solution:
1. Check .env has correct FIREBASE_PROJECT_ID
2. Verify service account credentials
3. Check Firebase project has Firestore enabled
```

**Problem: MQTT devices not connecting**
```bash
Solution:
1. Check MQTT broker URL and port
2. Verify credentials
3. Check firewall allows port 1883
4. See docs/IoT_SETUP.md
```

**Problem: API requests timeout**
```bash
Solution:
1. Check Node.js server is running
2. Verify network connectivity
3. Check rate limiting isn't triggered
4. See backend logs: npm run logs
```

### Getting Help

- 📖 Check [Documentation](./docs)
- 🐛 Search [Issues](../../issues)
- 💬 [Create a Discussion](../../discussions)
- 📧 Email: fandinof302@gmail.com

---

## 📊 Performance

### Benchmarks

- API response time: < 200ms (p95)
- Real-time updates: < 100ms latency
- Dashboard load time: < 2s on 4G
- Device sync frequency: 30-second intervals

### Optimization

- Query result caching (5-minute TTL)
- Lazy loading for chart data
- Image compression (WebP format)
- Database indexing on frequently queried fields

---

## 🗺️ Roadmap

### Q3 2026
- ✅ Core platform launched
- ✅ Mobile apps released
- ✅ MQTT device integration
- ⏳ Advanced analytics dashboard

### Q4 2026
- ⏳ Machine learning predictions
- ⏳ Scheduled automation rules
- ⏳ Multi-home support
- ⏳ API marketplace

### 2027
- ⏳ Enterprise features
- ⏳ Advanced reporting
- ⏳ Third-party integrations

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- Google Gemini API for AI capabilities
- Firebase team for excellent backend infrastructure
- Flutter team for cross-platform framework
- MQTT community for IoT protocols
- All contributors who have helped improve this project

---

## 📞 Contact

- **Author**: Fredy Esteban Fandiño
- **Email**: fandinof302@gmail.com
- **GitHub**: [@fredy200104](https://github.com/fredy200104)
- **Issues**: [Create an Issue](../../issues)

---

**Made with ❤️ and a passion for efficient energy management**

*Last updated: September 2, 2026*
