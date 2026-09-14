"""
Cryptographic utilities: AES-256-GCM, ECDSA signatures, Merkle trees.
"""
import hashlib
import hmac
import os
import json
from typing import List, Tuple, Optional
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend


# ─── AES-256-GCM Encryption ───

def generate_aes_key() -> bytes:
    """Generate a 256-bit AES key."""
    return AESGCM.generate_key(bit_length=256)


def aes_encrypt(plaintext: bytes, key: bytes) -> Tuple[bytes, bytes]:
    """Encrypt data with AES-256-GCM. Returns (nonce, ciphertext)."""
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)  # 96-bit nonce
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce, ciphertext


def aes_decrypt(nonce: bytes, ciphertext: bytes, key: bytes) -> bytes:
    """Decrypt AES-256-GCM data."""
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, None)


# ─── ECDSA Digital Signatures ───

def generate_ecdsa_keypair() -> Tuple[bytes, bytes]:
    """Generate ECDSA P-256 keypair. Returns (private_key_pem, public_key_pem)."""
    private_key = ec.generate_private_key(ec.SECP256R1(), default_backend())
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    public_pem = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    return private_pem, public_pem


def ecdsa_sign(data: bytes, private_key_pem: bytes) -> bytes:
    """Sign data with ECDSA P-256."""
    private_key = serialization.load_pem_private_key(private_key_pem, password=None)
    return private_key.sign(data, ec.ECDSA(hashes.SHA256()))


def ecdsa_verify(data: bytes, signature: bytes, public_key_pem: bytes) -> bool:
    """Verify ECDSA P-256 signature."""
    try:
        public_key = serialization.load_pem_public_key(public_key_pem)
        public_key.verify(signature, data, ec.ECDSA(hashes.SHA256()))
        return True
    except Exception:
        return False


# ─── Merkle Tree ───

class MerkleTree:
    """Simple Merkle tree for data integrity verification."""

    def __init__(self, data_blocks: List[bytes]):
        self.leaves = [self._hash(block) for block in data_blocks]
        self.root = self._build_tree(self.leaves)

    @staticmethod
    def _hash(data: bytes) -> str:
        return hashlib.sha256(data).hexdigest()

    def _build_tree(self, leaves: List[str]) -> str:
        if not leaves:
            return self._hash(b"")
        if len(leaves) == 1:
            return leaves[0]

        next_level = []
        for i in range(0, len(leaves), 2):
            left = leaves[i]
            right = leaves[i + 1] if i + 1 < len(leaves) else left
            combined = self._hash((left + right).encode())
            next_level.append(combined)

        return self._build_tree(next_level)

    def get_root(self) -> str:
        return self.root


def compute_data_hash(data: dict) -> str:
    """Compute deterministic hash of a dictionary."""
    serialized = json.dumps(data, sort_keys=True, default=str)
    return hashlib.sha256(serialized.encode()).hexdigest()


def compute_file_hash(filepath: str) -> str:
    """Compute SHA-256 hash of a file."""
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            sha256.update(chunk)
    return sha256.hexdigest()
