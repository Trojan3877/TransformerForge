// fast_attention.cpp
// ────────────────────────────────────────────────────────────────
// A high-performance softmax-scaled dot-product attention kernel
// written in C++17.  This CPU version is ~5-10× faster than naïve
// Python loops and provides the same extern "C" interface you’ll
// keep when replacing the inner loop with CUDA.
//
// Build (Linux/macOS):
//   g++ -O3 -march=native -std=c++17 -fPIC -shared fast_attention.cpp \
//       -o libfastattn.so
//
// Windows (MSVC):
//   cl /O2 /LD fast_attention.cpp /Fe:fastattn.dll
//
// NOTE: Replace the TODO section with a CUDA implementation for
// ml.g5.xlarge inference pods.
// ────────────────────────────────────────────────────────────────

#include <cmath>
#include <cstddef>
#include <vector>
#include <algorithm>
#include <limits>

extern "C" {

/**
 * Compute scaled dot-product attention for a single head.
 *
 * @param q          Pointer to query  vector  (size = seq_len × d_k)
 * @param k          Pointer to key    vector  (size = seq_len × d_k)
 * @param v          Pointer to value  vector  (size = seq_len × d_v)
 * @param out        Pointer to output vector  (size = seq_len × d_v)
 * @param seq_len    Sequence length (tokens)
 * @param d_k        Key / query dimension
 * @param d_v        Value dimension
 * @param scale      1/sqrt(d_k)  (pre-computed in Python for speed)
 */
void fast_attention(const float* q,
                    const float* k,
                    const float* v,
                    float*       out,
                    std::size_t  seq_len,
                    std::size_t  d_k,
                    std::size_t  d_v,
                    float        scale)
{
    // Temporary buffer for attention weights
    std::vector<float> attn(seq_len);

    for (std::size_t i = 0; i < seq_len; ++i)
    {
        // 1. Dot product Q_i with all K_j
        for (std::size_t j = 0; j < seq_len; ++j)
        {
            float dot = 0.0f;
            const float* qi = q + i * d_k;
            const float* kj = k + j * d_k;
            for (std::size_t d = 0; d < d_k; ++d)
                dot += qi[d] * kj[d];
            attn[j] = dot * scale;
        }

        // 2. Softmax (numerically stable)
        float max_logit = *std::max_element(attn.begin(), attn.end());
        float denom = 0.0f;
        for (float& a : attn) {
            a = std::exp(a - max_logit);
            denom += a;
        }
        for (float& a : attn) a /= denom;

        // 3. Weighted sum of V_j
        float* out_i = out + i * d_v;
        std::fill(out_i, out_i + d_v, 0.0f);

        for (std::size_t j = 0; j < seq_len; ++j)
        {
            const float* vj = v + j * d_v;
            float weight = attn[j];
            for (std::size_t d = 0; d < d_v; ++d)
                out_i[d] += weight * vj[d];
        }
    }
}

} // extern "C"
