#!/usr/bin/env python3
"""
Krishi-Saarthi Pre-Commit Security & Secret Scanner
--------------------------------------------------
Audits the repository before committing to Git to verify:
1. No unmasked API keys (Gemini, Google AI, CARTO, OpenAI, etc.)
2. No private keys, certificates, or keystores
3. No active .env files staged for commit
4. No machine-specific paths (e.g. local.properties, local user dirs)
5. No large binary model files (>50 MB) staged for commit

Usage:
    python3 scripts/security_check.py
"""

import os
import re
import sys
import subprocess

# Directories to skip when scanning files
IGNORED_DIRS = {
    '.git', 'node_modules', '.dart_tool', '__pycache__', 'venv', 
    '.venv', '.agents', '.vite', 'dist', 'build'
}

# Suspicious file patterns that must NEVER be committed
SENSITIVE_FILENAME_PATTERNS = [
    r'^\.env(\..+)?$',
    r'.*\.key$',
    r'.*\.pem$',
    r'.*\.keystore$',
    r'.*\.jks$',
    r'.*\.p12$',
    r'.*\.pfx$',
    r'^local\.properties$',
    r'^google-services\.json$',
    r'^GoogleService-Info\.plist$',
    r'.*\.db$',
    r'.*\.sqlite3?$',
]

# Sensitive content patterns
SECRET_REGEXES = [
    (re.compile(r'AIza[0-9A-Za-z-_]{35}'), 'Google AI / Maps API Key'),
    (re.compile(r'AQ\.[a-zA-Z0-9_\-]{40,}'), 'Google Gemini API Key'),
    (re.compile(r'sk-[a-zA-Z0-9]{24,}', re.I), 'OpenAI Secret Key'),
    (re.compile(r'AKIA[0-9A-Z]{16}'), 'AWS Access Key ID'),
    (re.compile(r'cb1_[0-9a-zA-Z_]{20,}'), 'CARTO API Key'),
    (re.compile(r'-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'), 'Private Key Header'),
    (re.compile(r'flutter\.sdk\s*=\s*/Users/'), 'Machine-Specific User SDK Path'),
]

# Files explicitly exempt from regex content checking (e.g. scanner itself, documentation)
EXEMPT_FILES = {
    'scripts/security_check.py',
    'SECURITY.md',
    '.env.example',
    'backend/.env.example',
}


def check_git_staged_files():
    """Check files staged in git index."""
    try:
        res = subprocess.run(['git', 'diff', '--name-only', '--cached'], capture_output=True, text=True)
        if res.returncode == 0:
            staged = [f.strip() for f in res.stdout.splitlines() if f.strip()]
            return staged
    except Exception:
        pass
    return []


def scan_repository():
    violations = []
    print("=" * 70)
    print("🌾 Krishi-Saarthi Pre-Commit Security & Privacy Audit")
    print("=" * 70)

    # 1. Check Git Staged Files
    staged = check_git_staged_files()
    if staged:
        print(f"[*] Auditing {len(staged)} staged file(s) in Git index...")
        for filepath in staged:
            basename = os.path.basename(filepath)
            for pat in SENSITIVE_FILENAME_PATTERNS:
                if re.match(pat, basename, re.IGNORECASE) and not basename.endswith('.example'):
                    violations.append(f"[STAGED FILE ERROR] Sensitive file staged: {filepath}")

    # 2. Scan File System
    print("[*] Scanning repository source tree for accidental secret leaks...")
    file_count = 0
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]
        for fname in files:
            filepath = os.path.normpath(os.path.join(root, fname))
            relpath = filepath.lstrip('./')

            # Check if file is ignored by git
            is_ignored = subprocess.run(['git', 'check-ignore', '-q', filepath]).returncode == 0
            if is_ignored:
                continue

            # Check filename
            for pat in SENSITIVE_FILENAME_PATTERNS:
                if re.match(pat, fname, re.IGNORECASE) and not fname.endswith('.example'):
                    violations.append(f"[UNIGNORED FILE] {filepath} should be added to .gitignore!")

            # Check file size (no single file over 50MB should be committed without Git LFS)
            try:
                size_mb = os.path.getsize(filepath) / (1024 * 1024)
                if size_mb > 50:
                    violations.append(f"[LARGE FILE >50MB] {filepath} ({size_mb:.1f}MB) is NOT ignored!")
            except OSError:
                pass

            # Check contents of code and configuration files
            if relpath in EXEMPT_FILES or not fname.endswith(
                ('.py', '.dart', '.js', '.ts', '.html', '.json', '.yaml', '.yml', '.md', '.sh', '.properties')
            ):
                continue

            file_count += 1
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    for lno, line in enumerate(f, 1):
                        for regex, description in SECRET_REGEXES:
                            match = regex.search(line)
                            if match:
                                # Mask token in report
                                val = match.group(0)
                                masked = val[:6] + "..." + val[-4:] if len(val) > 10 else "***"
                                violations.append(
                                    f"[HARDCODED SECRET] {filepath}:{lno} - {description} found ({masked})"
                                )
            except Exception as e:
                violations.append(f"[READ ERROR] Could not read {filepath}: {e}")

    print(f"[*] Audited {file_count} text/code files.")
    print("=" * 70)

    if violations:
        print(f"❌ FAILED: {len(violations)} security violation(s) detected:\n")
        for v in violations:
            print(f"  • {v}")
        print("\nPlease fix the above items before committing to Git.")
        return False
    else:
        print("✅ SUCCESS: 0 secrets or sensitive file leaks detected!")
        print("   The repository is clean and safe to commit / push to GitHub.")
        return True


if __name__ == '__main__':
    success = scan_repository()
    sys.exit(0 if success else 1)

# Agri-Saarthi 2026 Sync
