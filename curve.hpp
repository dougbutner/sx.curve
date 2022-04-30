#pragma once

#include "include/sx.safemath/safemath.hpp"

using namespace eosio;

namespace Curve {
    const int MAX_ITERATIONS = 10;
    /**
     * ## STATIC `get_amount_out`
     *
     * Given an input amount, reserves pair and amplifier, returns the output amount of the other asset based on Curve formula
     * Whitepaper: https://www.curve.fi/stableswap-paper.pdf
     * Python implementation: https://github.com/curvefi/curve-contract/blob/master/tests/simulation.py
     *
     * ### params
     *
     * - `{uint64_t} amount_in` - amount input
     * - `{uint64_t} reserve_in` - reserve input
     * - `{uint64_t} reserve_out` - reserve output
     * - `{uint64_t} amplifier` - amplifier
     * - `{uint8_t} fee` - trade fee (pips 1/100 of 1%)
     *
     * ### example
     *
     * ```c++
     * // Inputs
     * const uint64_t amount_in = 100000;
     * const uint64_t reserve_in = 3432247548;
     * const uint64_t reserve_out = 6169362700;
     * cont uint64_t amplifier = 450;
     * const uint8_t fee = 4;
     *
     * // Calculation
     * const uint64_t amount_out = curve::get_amount_out( amount_in, reserve_in, reserve_out, amplifier, fee );
     * // => 100110
     * ```
     */
    static uint64_t get_amount_out( const uint64_t amount_in, const uint64_t reserve_in, const uint64_t reserve_out, const uint64_t amplifier, const uint8_t fee )
    {
        eosio::check(amount_in > 0, "curve.sx::get_amount_out: insufficient input amount");
        eosio::check(amplifier > 0, "curve.sx::get_amount_out: invalid amplifier");
        eosio::check(reserve_in > 0 && reserve_out > 0, "curve.sx::get_amount_out: insufficient liquidity");
        eosio::check(reserve_in < (1LL << 62) - 1 && reserve_out < (1LL << 62) - 1, "curve.sx::get_amount_out: invalid reserves");

        // calculate invariant D by solving quadratic equation:
        // A * sum * n^n + D = A * D * n^n + D^(n+1) / (n^n * prod), where n==2
        const uint64_t sum = reserve_in + reserve_out;
        uint128_t D = sum, D_prev = 0;
        int i = MAX_ITERATIONS;
        while ( D != D_prev && i--) {
            uint128_t prod1 = D * D / (reserve_in * 2) * D / (reserve_out * 2);
            D_prev = D;
            check((uint64_t)(safemath::mul( amplifier, sum ) + prod1) == safemath::mul( amplifier, sum ) + prod1, "curve.sx::get_amount_out: d1 overflow");
            D = 2 * D * (safemath::mul(amplifier, sum) + prod1) / ((2 * amplifier - 1) * D + 3 * prod1);
        }

        // calculate x - new value for reserve_out by solving quadratic equation iteratively:
        // x^2 + x * (sum' - (An^n - 1) * D / (An^n)) = D ^ (n + 1) / (n^(2n) * prod' * A), where n==2
        // x^2 + b*x = c
        check((uint64_t)D == D, "curve.sx::get_amount_out: d2 overflow");
        const int128_t b = (int128_t) ((reserve_in + amount_in) + (D / (amplifier * 2))) - (int128_t) D;
        const uint128_t c = D * D / ((reserve_in + amount_in) * 2) * D / (amplifier * 4);
        uint128_t x = D, x_prev = 0;
        i = MAX_ITERATIONS;
        while ( x != x_prev && i--) {
            x_prev = x;
            x = (x * x + c) / (2 * x + b);
        }
        check(reserve_out > x, "curve.sx::get_amount_out: insufficient reserve out");
        const uint64_t amount_out = reserve_out - (uint64_t)x;

        return amount_out - fee * amount_out / 10000;
    }
}
