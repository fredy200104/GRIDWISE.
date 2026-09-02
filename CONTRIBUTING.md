# Contributing to GRIDWISE

Thank you for your interest in contributing to GRIDWISE! We welcome developers, designers, and energy enthusiasts.

## 🎯 Ways to Contribute

- 🐛 **Report Bugs** — Find a bug? [Open an issue](../../issues/new?template=bug_report.md)
- ✨ **Suggest Features** — Have an idea? [Request a feature](../../issues/new)
- 📖 **Improve Docs** — Documentation could be clearer? Submit a PR
- 💻 **Write Code** — Implement features or fix bugs
- 🧪 **Write Tests** — Improve test coverage
- 🎨 **Design** — UI/UX improvements welcome

## 🚀 Getting Started

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/GRIDWISE.git
cd GRIDWISE
git remote add upstream https://github.com/fredy200104/GRIDWISE.git
```

### 2. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Set Up Development Environment

**Backend:**
```bash
cd gridwise-backend
npm install
cp .env.example .env
# Edit .env with your credentials
npm run dev
```

**Frontend:**
```bash
cd lib
flutter pub get
flutter run
```

### 4. Make Changes

Follow our code style and conventions (see below).

### 5. Test Your Changes

```bash
# Backend
cd gridwise-backend
npm test
npm run lint

# Frontend
cd lib
flutter test
flutter analyze
```

### 6. Commit & Push

```bash
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature-name
```

### 7. Create Pull Request

1. Go to https://github.com/fredy200104/GRIDWISE
2. Click "Compare & pull request"
3. Fill in the PR template
4. Submit for review

## 📝 Commit Messages

We use **Conventional Commits**:

```
type(scope): subject

body

footer
```

### Types

- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation changes
- `style:` — Code style (no logic change)
- `refactor:` — Code refactoring
- `test:` — Adding or updating tests
- `chore:` — Build, dependencies, etc.
- `security:` — Security improvements

### Examples

```
feat(auth): add OAuth 2.0 Google integration

fix(api): resolve CORS issue with mobile clients

docs: update installation guide for Windows

security: implement rate limiting on login endpoint

test: add unit tests for energy calculation service
```

## 🎨 Code Style

### Python/Node.js

```javascript
// Use semicolons
const myFunction = () => {
  return "example";
};

// Use const by default
const value = 42;

// Use meaningful names
const energyConsumption = calculateUsage(); // ✓ Good
const ec = calculateUsage();                 // ✗ Avoid

// Comment only when necessary
// Calculate daily average using exponential moving average
const ema = calculateEMA(data, 30);
```

### Dart (Flutter)

```dart
// Follow Dart conventions
class EnergyCalculator {
  final String deviceId;
  
  EnergyCalculator(this.deviceId);
  
  /// Calculate energy consumption for the given period.
  /// 
  /// Returns consumption in kWh.
  double calculateConsumption(DateTime start, DateTime end) {
    // Implementation
    return 0.0;
  }
}
```

### General Rules

- Max line length: 100 characters
- Use 2-space indentation
- Use meaningful variable names
- Comment complex logic
- No console.log() in production code
- Add docstrings/comments to public functions

## ✅ Code Quality

### Before Submitting PR

- [ ] Code passes all tests: `npm test` or `flutter test`
- [ ] No linting errors: `npm run lint` or `flutter analyze`
- [ ] Code follows our style guide
- [ ] Added tests for new features
- [ ] Updated documentation
- [ ] Commit messages follow conventions
- [ ] No hardcoded secrets/credentials
- [ ] No console.log() left behind

### Checklist for PR

- [ ] PR title clearly describes the change
- [ ] PR description includes motivation
- [ ] Related issues are linked (Fixes #123)
- [ ] Changes are focused (not too broad)
- [ ] No unnecessary dependencies added
- [ ] Documentation updated (if needed)
- [ ] Screenshots/videos (if UI change)

## 🧪 Testing Requirements

- **New features** require tests (minimum 80% coverage)
- **Bug fixes** should include a test that would fail without the fix
- **Documentation** changes don't need tests

### Running Tests

```bash
# Unit tests only
npm run test:unit

# All tests with coverage
npm run test:coverage

# Watch mode (auto-rerun on changes)
npm run test:watch
```

## 📚 Documentation

When contributing, update relevant docs:

- **New API endpoint** → Update `docs/API.md`
- **New configuration** → Update `docs/DEPLOYMENT.md`
- **New IoT feature** → Update `docs/IoT_SETUP.md`
- **Bug with security impact** → Update `SECURITY.md`

## 🔐 Security Guidelines

- Never commit `.env` files
- Never hardcode API keys or secrets
- Use environment variables for sensitive data
- Validate all user input
- Follow OWASP Top 10 principles
- For security vulnerabilities, see [SECURITY.md](./SECURITY.md)

## 🤔 Questions?

- 📖 Check [Documentation](./docs)
- 💬 Search [Issues](../../issues) for similar questions
- 📧 Email: fandinof302@gmail.com
- 👥 Join our community discussions

## 🎓 Learning Resources

- [Node.js Best Practices](https://nodejs.org/en/docs/guides/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter & Dart Guide](https://flutter.dev/docs)
- [MQTT Protocol Overview](http://mqtt.org/)

## 📋 Pull Request Process

1. **Before creating PR:**
   - Check if issue already exists
   - Discuss major changes first
   - Ensure your branch is up-to-date with main

2. **After creating PR:**
   - We'll review within 2-3 business days
   - Respond to feedback promptly
   - Make requested changes
   - Request re-review when ready

3. **After approval:**
   - PR will be merged to main
   - Your contribution is live! 🎉

## 🏆 Recognition

- Contributors will be listed in [CONTRIBUTORS.md]
- Major contributions may receive special recognition
- You get to say you helped build GRIDWISE!

## 📜 Code of Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). Be respectful and inclusive.

---

**Thank you for contributing to GRIDWISE!** ✨

*Questions? Open an issue or email fandinof302@gmail.com*
