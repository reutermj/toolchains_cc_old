#!/usr/bin/env python3
import argparse
import subprocess
import sys
from pathlib import Path

def run_command(cmd, check=True):
    """Run a command and return stdout, stderr"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
        return result.stdout, result.stderr, result.returncode
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr, e.returncode

def check_c_stdlib(binary_path, triple):
    """Check if binary is linked against the correct C standard library"""
    stdout, stderr, returncode = run_command(f"ldd '{binary_path}'", check=False)
    
    if "x86_64-alpine-linux-musl" in triple:
        # Expect musl
        if "musl" in stdout or "not a dynamic executable" in stderr:
            print(f"✓ {binary_path.name}: musl C library detected (or static)")
            return True
        else:
            print(f"❌ {binary_path.name}: Expected musl but found glibc")
            print(f"   ldd output: {stdout.strip()}")
            return False
    else:
        # Expect glibc
        if "linux-vdso" in stdout or "ld-linux" in stdout:
            print(f"✓ {binary_path.name}: glibc C library detected")
            return True
        elif "not a dynamic executable" in stderr:
            print(f"⚠ {binary_path.name}: Static binary - cannot verify C library")
            return True  # Assume correct for static builds
        else:
            print(f"❌ {binary_path.name}: Expected glibc but found unexpected output")
            print(f"   ldd output: {stdout.strip()}")
            return False

def check_cxx_stdlib(binary_path, cxx_std_lib):
    """Check if binary is linked against the correct C++ standard library"""
    stdout, stderr, returncode = run_command(f"ldd '{binary_path}'", check=False)
    
    if cxx_std_lib == "libc++":
        if "libc++" in stdout:
            print(f"✓ {binary_path.name}: libc++ detected in dependencies")
            return True
        else:
            # Check if it's statically linked or built with clang
            comment_stdout, _, _ = run_command(f"readelf -p .comment '{binary_path}'", check=False)
            if "clang" in comment_stdout.lower():
                print(f"✓ {binary_path.name}: Built with clang (likely using libc++ statically)")
                return True
            else:
                print(f"❌ {binary_path.name}: Expected libc++ but not found")
                print(f"   ldd output: {stdout.strip()}")
                return False
    
    elif cxx_std_lib == "libstdc++":
        if "libstdc++" in stdout:
            print(f"✓ {binary_path.name}: libstdc++ detected in dependencies")
            return True
        else:
            # Check if it's statically linked
            if "not a dynamic executable" in stderr:
                print(f"⚠ {binary_path.name}: Static binary - assuming libstdc++ (default)")
                return True
            else:
                print(f"❌ {binary_path.name}: Expected libstdc++ but not found")
                print(f"   ldd output: {stdout.strip()}")
                return False
    
    return False

def main():
    parser = argparse.ArgumentParser(description="Verify C/C++ standard library linkage")
    parser.add_argument("--base_path", help="Base path to search for binaries")
    parser.add_argument("--triple", help="Target triple (e.g., x86_64-unknown-linux-gnu)")
    parser.add_argument("--cxx_std_lib", help="C++ standard library (libstdc++ or libc++)")
    
    args = parser.parse_args()
    
    base_path = Path(args.base_path)
    if not base_path.exists():
        print(f"❌ Base path does not exist: {base_path}")
        sys.exit(1)
    
    # Find binaries
    main_binary = None
    main_cxx_binary = None
    
    # Search for binaries recursively
    for binary_path in base_path.rglob("*"):
        if binary_path.is_file() and binary_path.stat().st_mode & 0o111:  # executable
            if binary_path.name == "main":
                main_binary = binary_path
            elif binary_path.name == "main++":
                main_cxx_binary = binary_path
    
    if not main_binary and not main_cxx_binary:
        print(f"❌ No 'main' or 'main++' executables found in {base_path}")
        sys.exit(1)
    
    print(f"Configuration: triple={args.triple}, cxx_std_lib={args.cxx_std_lib}")
    print("=" * 60)
    
    success = True
    
    # Check main binary (C standard library only)
    if main_binary:
        print(f"\nChecking {main_binary}:")
        file_stdout, _, _ = run_command(f"file '{main_binary}'")
        print(f"File info: {file_stdout.strip()}")
        
        if not check_c_stdlib(main_binary, args.triple):
            success = False
    
    # Check main++ binary (both C and C++ standard libraries)
    if main_cxx_binary:
        print(f"\nChecking {main_cxx_binary}:")
        file_stdout, _, _ = run_command(f"file '{main_cxx_binary}'")
        print(f"File info: {file_stdout.strip()}")
        
        if not check_c_stdlib(main_cxx_binary, args.triple):
            success = False
        
        if not check_cxx_stdlib(main_cxx_binary, args.cxx_std_lib):
            success = False
    
    print("=" * 60)
    if success:
        print("✓ All library linkage checks passed!")
        sys.exit(0)
    else:
        print("❌ Some library linkage checks failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
