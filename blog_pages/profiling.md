@def title = "But what is Performance Analysis and profiling?"
@def date = Date(2025, 08, 31)
@def description = "Understanding performance analysis and profiling using tools like AMD uProf and perf"


\toc

## Introduction

Performance profiling helps us understand how our code executes on real hardware and identify bottlenecks. Using tools like `perf` on Linux, we can collect hardware performance counters to gain deep insights into cache behavior, instruction execution, and branch prediction.

## Matrix Multiplication Profiling Results

In the ~~~<a href="../mat_mul/">Matrix Multiplication blog</a>~~~, we implemented several cache-aware optimizations. Here we profile each approach using `perf` on Linux with a 4096×4096 matrix size to understand their performance characteristics.

### Experimental Setup

**System Specifications:**
```
OS: Garuda Linux x86_64
Host: Victus by HP Laptop 16-e0xxx
Kernel: 6.7.9-zen1-1-zen

CPU: AMD Ryzen 5 5600H (6 cores, 12 threads) @ 4.28 GHz
  - L1 Cache: 384 KB
  - L2 Cache: 3 MB
GPU: AMD Radeon RX 5500M
GPU: AMD Radeon Vega Series / Radeon Vega Mobile Series
Memory: 16 GB DDR4
```

**Compilation Command:**
```bash
g++ -mavx -mfma -march=native -O0 -o simd_matmul \
    ../../../matmul_perf_profiling-master/specific_runner.cpp
```

**Profiling Command:**
```bash
sudo perf stat -e "L1-dcache-loads,L1-dcache-load-misses,\
L1-dcache-prefetches,L1-icache-loads,L1-icache-load-misses,\
dTLB-loads,dTLB-load-misses,iTLB-loads,iTLB-load-misses,\
branch-loads,branch-load-misses,branch-instructions,branch-misses,\
cache-misses,cache-references,cpu-cycles,instructions" -C 3 \
numactl -C 3 ./<bin_name>
```

Note: We used `-O0` (no compiler optimizations) to isolate the impact of our manual cache-aware optimizations. The code was pinned to CPU core 3 using `numactl` to ensure consistent measurements.

### Performance Comparison Table

| Approach | Time (s) | Speedup | IPC | L1 D-cache Loads | L1 D-cache Misses | L1 D-Miss Rate | Cache Refs | Cache Miss Rate |
|----------|----------|---------|-----|------------------|-------------------|----------------|------------|----------------|
| Simple MatMul | 268.27 | 1.00× | 1.70 | 486.39B | 71.92B | 14.79% | 188.35B | 45.85% |
| Loop Reordered | 148.63 | ~~~<span class="positive">↓</span>~~~ 1.80× | ~~~<span class="positive">↑</span>~~~ 5.20 | ~~~<span class="positive">↑</span>~~~ 895.81B | ~~~<span class="positive">↓</span>~~~ 5.69B | ~~~<span class="positive">↓</span>~~~ 0.64% | ~~~<span class="positive">↓</span>~~~ 11.16B | ~~~<span class="positive">↓</span>~~~ 2.04% |
| Half Tiled | 146.10 | ~~~<span class="positive">↓</span>~~~ 1.84× | ~~~<span class="positive">↑</span>~~~ 5.27 | ~~~<span class="positive">↑</span>~~~ 896.14B | ~~~<span class="positive">↓</span>~~~ 5.60B | ~~~<span class="positive">↓</span>~~~ 0.62% | ~~~<span class="positive">↓</span>~~~ 10.99B | ~~~<span class="positive">↓</span>~~~ 1.98% |
| Inner Tiled (512) | 148.35 | ~~~<span class="positive">↓</span>~~~ 1.81× | ~~~<span class="positive">↑</span>~~~ 5.19 | ~~~<span class="positive">↑</span>~~~ 896.33B | ~~~<span class="positive">↓</span>~~~ 5.78B | ~~~<span class="positive">↓</span>~~~ 0.65% | ~~~<span class="positive">↓</span>~~~ 11.31B | ~~~<span class="positive">↓</span>~~~ 2.64% |
| Inner Tiled (64) | 148.68 | ~~~<span class="positive">↓</span>~~~ 1.80× | ~~~<span class="positive">↑</span>~~~ 5.18 | ~~~<span class="positive">↑</span>~~~ 895.92B | ~~~<span class="positive">↓</span>~~~ 5.79B | ~~~<span class="positive">↓</span>~~~ 0.65% | ~~~<span class="positive">↓</span>~~~ 11.39B | ~~~<span class="positive">↓</span>~~~ 2.32% |
| Fully Tiled (512) | 281.01 | ~~~<span class="negative">↑</span>~~~ 0.95× | ~~~<span class="positive">↑</span>~~~ 4.32 | ~~~<span class="negative">↑</span>~~~ 1,508.94B | ~~~<span class="positive">↓</span>~~~ 6.13B | ~~~<span class="positive">↓</span>~~~ 0.41% | ~~~<span class="negative">↑</span>~~~ 21.09B | ~~~<span class="negative">↑</span>~~~ 26.13% |
| Fully Tiled (64) | 270.62 | ~~~<span class="negative">↑</span>~~~ 0.99× | ~~~<span class="positive">↑</span>~~~ 4.52 | ~~~<span class="negative">↑</span>~~~ 1,480.69B | ~~~<span class="negative">↑</span>~~~ 11.10B | ~~~<span class="positive">↓</span>~~~ 0.75% | ~~~<span class="negative">↑</span>~~~ 26.95B | ~~~<span class="negative">↑</span>~~~ 22.88% |
| SIMD MatMul | 46.39 | ~~~<span class="positive">↓</span>~~~ 5.78× | ~~~<span class="positive">↑</span>~~~ 2.58 | ~~~<span class="negative">↑</span>~~~ 1,877.24B | ~~~<span class="positive">↓</span>~~~ 5.22B | ~~~<span class="positive">↓</span>~~~ 2.78% | ~~~<span class="positive">↓</span>~~~ 10.26B | ~~~<span class="positive">↓</span>~~~ 1.64% |

### Key Observations

1. **SIMD is King**: The SIMD implementation achieves a remarkable 5.78× speedup (46.39s), crushing all scalar implementations. This is the power of data-level parallelism through AVX/FMA instructions.

2. **Loop Reordering is Transformational**: Simple loop reordering achieves a 1.80× speedup and dramatically improves IPC from 1.70 to 5.20, while reducing L1 D-cache miss rate from 14.79% to 0.64%. This is the most impactful scalar optimization.

3. **Half Tiling Edges Ahead**: Among scalar implementations, the half-tiled approach provides the best performance at 146.10s (1.84× speedup) with an IPC of 5.27, though the improvement over loop reordering is only 2%.

4. **Inner Tiling Shows Minimal Benefit**: Both inner tile sizes (512 and 64) perform virtually identically to simple loop reordering, maintaining excellent IPC (~5.18-5.19) and low cache miss rates (~2.3-2.6%). The added complexity provides no measurable benefit.

5. **Full Tiling Catastrophically Regresses**: Both fully tiled implementations (512 and 64 tile sizes) perform **worse than the baseline**, taking 281s and 271s respectively. Despite having the lowest L1 D-cache miss rates (0.41% and 0.75%), they suffer from:
   - 2.6× more instructions executed (4,892B vs 1,860B)
   - 3× more L1 D-cache loads (1,509B vs 486B)
   - Massively increased cache references (21-27B vs 11B)
   - Severe cache pollution (26.13% and 22.88% cache miss rates)

6. **SIMD's Interesting Tradeoff**: While SIMD is fastest overall, it has:
   - Lower IPC (2.58) than cache-optimized scalar code (5.20)
   - Higher L1 D-cache miss rate (2.78%) than optimized scalar (0.64%)
   - But compensates through vectorization: processing 8 floats per instruction
   - Still achieves excellent cache reference efficiency (1.64% miss rate vs 45.85% baseline)

### Detailed Metrics

#### Instructions and Cycles
| Approach | Instructions | CPU Cycles | IPC | Branch Miss Rate |
|----------|-------------|------------|-----|-----------------|
| Simple MatMul | 1,860.63B | 1,092.93B | 1.70 | 0.11% |
| Loop Reordered | 3,096.26B | 595.10B | ~~~<span class="positive">↑</span>~~~ 5.20 | ~~~<span class="positive">↓</span>~~~ 0.07% |
| Inner Tiled (512) | 3,097.33B | 597.09B | ~~~<span class="positive">↑</span>~~~ 5.19 | ~~~<span class="positive">↓</span>~~~ 0.07% |
| Inner Tiled (64) | 3,095.96B | 597.28B | ~~~<span class="positive">↑</span>~~~ 5.18 | ~~~<span class="positive">↓</span>~~~ 0.07% |

**Key Insight**: The optimized versions execute ~66% more instructions but complete in ~45% fewer cycles, resulting in 3× higher IPC. This demonstrates that instruction count alone is a poor performance metric—what matters is how efficiently the CPU pipeline can execute those instructions.

#### Cache Behavior
| Approach | L1 D-cache Loads | L1 D-cache Misses | Miss Rate | L1 D-cache Prefetches |
|----------|-----------------|-------------------|-----------|----------------------|
| Simple MatMul | 486.39B | 71.92B | 14.79% | 27.07B |
| Loop Reordered | 895.81B | ~~~<span class="positive">↓</span>~~~ 5.69B | ~~~<span class="positive">↓</span>~~~ 0.64% | ~~~<span class="positive">↓</span>~~~ 4.91B |
| Inner Tiled (512) | 896.33B | ~~~<span class="positive">↓</span>~~~ 5.78B | ~~~<span class="positive">↓</span>~~~ 0.65% | ~~~<span class="positive">↓</span>~~~ 4.92B |
| Inner Tiled (64) | 895.92B | ~~~<span class="positive">↓</span>~~~ 5.79B | ~~~<span class="positive">↓</span>~~~ 0.65% | ~~~<span class="positive">↓</span>~~~ 4.95B |

**Key Insight**: Despite nearly doubling the number of L1 D-cache loads (from 486B to 896B), the optimized versions reduce cache misses by 92% (from 71.92B to ~5.7B). This dramatic improvement in miss rate demonstrates the power of spatial locality.

### Analysis

The profiling data reveals several important insights:

1. **Data-Level Parallelism Dominates**: SIMD vectorization (5.78× speedup) provides 3× better performance than the best cache optimization (1.84× speedup). When applicable, vectorization is the single most impactful optimization technique.

2. **Memory Access Patterns Matter Most (for Scalar Code)**: Among scalar implementations, simple loop reordering has the most dramatic impact, reducing L1 D-cache misses by 92% (from 71.92B to 5.69B) by improving spatial locality. This single change delivers 1.80× speedup.

3. **IPC as a Key Metric for Scalar Code**: The cache-optimized scalar versions achieve 3× higher IPC (from 1.70 to ~5.20), indicating much better CPU pipeline utilization with fewer stalls waiting for memory. This high IPC shows the CPU pipeline running at near-peak efficiency.

4. **SIMD's Different Performance Profile**: SIMD has lower IPC (2.58) than scalar optimized code (5.20), but wins through throughput—each instruction processes 8 floats instead of 1. This demonstrates that **IPC alone is not a complete performance metric** when comparing scalar vs vector code.

5. **Diminishing Returns from Complex Tiling**: Additional inner tiling optimizations provide virtually no benefit over simple loop reordering for this 4096×4096 matrix size. Performance varies by less than 0.5% between loop reordering, half tiling, and inner tiling.

6. **The Fully Tiled Catastrophe**: Full tiling performs worse than even the baseline! Despite achieving the best L1 D-cache miss rates, it suffers from:
   - **Loop overhead**: 2.6× more instructions due to nested loop complexity
   - **Cache pollution**: Irregular access patterns cause 26% cache miss rates at higher levels
   - **TLB pressure**: More complex addressing increases virtual-to-physical translation overhead
   
   This proves that **optimizing for one metric (L1 miss rate) can harm overall performance**.

7. **The Paradox of More Instructions**: Cache-optimized scalar code executes 66% more instructions (3,096B vs 1,860B) but runs 45% faster. The fully tiled code executes 2.6× more instructions and runs slower. This shows instruction count correlates with performance only when memory behavior is similar.

8. **Hardware Prefetching Adapts to Code Quality**: 
   - Poor locality code (simple matmul): 27B prefetches → trying to compensate
   - Good locality code (optimized): ~5B prefetches → works efficiently
   - This suggests modern prefetchers work best with already-good code, rather than fixing bad code.

9. **Branch Prediction Impact**: Branch miss rate decreases from 0.11% to 0.07% in optimized versions. While already excellent, this 36% reduction contributes to the performance gain. Modern CPUs have remarkably good branch predictors.

### What We Learned

Using `perf` to collect hardware performance counters provides invaluable insights that wall-clock time alone cannot reveal:

- **Vectorization (SIMD)** is the most powerful optimization when applicable
- **Memory locality** is the most important factor for scalar code performance
- **IPC** is meaningful only when comparing similar code (scalar vs scalar, SIMD vs SIMD)
- **Cache miss rate** matters, but only at the right level—L1 optimization can hurt LLC/DRAM performance
- **Instruction count** is almost meaningless without memory and execution context
- **Simple, predictable access patterns** enable both cache efficiency and hardware prefetching
- **Over-optimization can hurt**: Complexity has real costs in instructions and cache behavior

The key lesson: **Focus on the right optimization for your bottleneck**. For this workload:
1. First: Add SIMD (5.78× speedup)
2. Second: Fix memory access patterns (1.80× speedup)  
3. Third: Stop—additional complexity provides no benefit

