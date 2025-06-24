"""
benchmark_attention.py
────────────────────────────────────────────────────────────────────────────
Compares TransformerForge’s C++ flash-attention kernel against
PyTorch’s built-in scaled-dot-product attention (SDPA).

Usage:
    python scripts/benchmark_attention.py --seq 128 --dk 64 --dv 64 --iter 100

Output:
    ┌──────────────────────────────┬─────────┬─────────┐
    │ Implementation               │  Avg ms │ Speedup │
    ├──────────────────────────────┼─────────┼─────────┤
    │ C++  (libfastattn.so)        │   1.94  │  8.3×   │
    │ PyTorch SDPA (CPU)           │  16.16  │  1.0×   │
    └──────────────────────────────┴─────────┴─────────┘
"""

import argparse
import time
import numpy as np
import torch
from attention import fast_attention_np, fast_attention_torch
from tabulate import tabulate


def bench(func, *a, iters: int = 100):
    start = time.time()
    for _ in range(iters):
        func(*a)
    return (time.time() - start) * 1000 / iters  # ms


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seq", type=int, default=128)
    ap.add_argument("--dk", type=int, default=64)
    ap.add_argument("--dv", type=int, default=64)
    ap.add_argument("--iter", type=int, default=100)
    args = ap.parse_args()

    q = np.random.rand(args.seq, args.dk).astype(np.float32)
    k = np.random.rand(args.seq, args.dk).astype(np.float32)
    v = np.random.rand(args.seq, args.dv).astype(np.float32)

    torch_q = torch.from_numpy(q)
    torch_k = torch.from_numpy(k)
    torch_v = torch.from_numpy(v)

    cxx_ms = bench(fast_attention_np, q, k, v, iters=args.iter)
    torch_ms = bench(
        lambda: fast_attention_torch(torch_q, torch_k, torch_v),
        iters=args.iter,
    )

    table = [
        ["C++  (libfastattn.so)", f"{cxx_ms:6.2f}", f"{torch_ms/ cxx_ms:4.1f}×"],
        ["PyTorch SDPA (CPU)", f"{torch_ms:6.2f}", "1.0×"],
    ]
    print(tabulate(table, headers=["Implementation", "Avg ms", "Speedup"], tablefmt="fancy_grid"))


if __name__ == "__main__":
    main()
