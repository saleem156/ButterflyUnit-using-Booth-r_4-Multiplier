# ButterflyUnit-using-Booth-r_4-Multiplier

## Overview

This project presents a hardware implementation of a radix-2 Gentleman-Sande (GS) Butterfly Unit using a **Radix-4 Booth multiplier for modular multiplication.

The architecture is intended for **Number Theoretic Transform (NTT) applications, especially for post-quantum cryptography algorithms such as CRYSTALS-Kyber / ML-KEM.

1. What a Butterfly Unit does

It's the basic repeating computation in an FFT. For each pair of inputs A and B, it produces:

X = A + (W × B)
Y = A − (W × B)

W is called the "twiddle factor" — a complex number that rotates B before combining it with A. So each butterfly does one multiplication and two add/subtract operations. Thousands of these are chained together to build a full FFT, so making each one fast and small matters a lot.

2. Why Booth Radix-4 for the multiplier

The multiplication (W × B) is the expensive part — way more hardware than the add/subtract. A plain multiplier adds up one partial product per bit of the multiplier, which is slow for wide numbers.

Booth's technique speeds this up by recoding the multiplier bits so fewer partial products are needed:

Radix-2 Booth: looks at bits 2 at a time, picks a multiple of 0, +1, or −1 → produces n partial products for an n-bit number.
Radix-4 Booth (what this project uses): looks at bits 3 at a time (overlapping), picks a multiple of 0, ±1, or ±2 → produces only n/2 partial products.

Half as many partial products means half as many rows to add together, which means a shorter, faster adder tree and less silicon area. That's the whole payoff: same multiplication, done with roughly half the hardware stages.


The Booth Radix-4 multiplier computes W × B, and the butterfly unit's adder/subtractor takes that result along with A to produce X and Y. So the project is really two parts: a fast multiplier core, and simple add/subtract logic wrapped around it
