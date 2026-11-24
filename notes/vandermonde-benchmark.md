# Vandermonde benchmark and Bezanson's thesis

Background notes for Island 1 (Accessible Performance), slide 2.2 "Reads like Python, runs like C". The benchmark the talk uses is in [bench/vandermonde/](../bench/vandermonde/) and explained in the deep dive `deepdive/vandermonde.nim`; this file is the why, from an earlier exploration (2026-11-24) that reproduced the thesis' table with NumPy and Nim.

## Why this benchmark

Jeff Bezanson's MIT thesis, *Abstraction in Technical Computing* (2015, advisor Alan Edelman), opens its domain chapter with a case study: NumPy's `vander` function. Section 2.1.1 shows NumPy's user-level Python implementation, figure 2-1 shows the same thing in Julia, and table 2.1 times both. It is the canonical statement of the two-language problem in a single page of code, by the person who built a language to answer it, which makes it a better example for the slide than a synthetic microbenchmark, because it comes with an argument attached rather than just a ratio.

The original numbers (2015 hardware, Julia 0.3-era), 4·10⁶ points either as many tiny matrices or one big one:

| Size | # iter | NumPy | Julia | Julia with dispatch |
|---|---|---|---|---|
| 4×4 | 250000 | 5.43 | 0.072 | 0.204 |
| 2000×2000 | 1 | 0.420 | 0.037 | 0.037 |

Bezanson's reading: for small matrices the two-language dispatch overhead swamps the computation, and his closing line is the one worth quoting on a slide — abstraction overhead is important and involves the whole program, not just inner loops.

## What the earlier exploration found

It ran the thesis' own NumPy `vander` and a Nim port on the thesis' two cases (4×4 ×250 000 and 2000×2000, `-d:danger`, values in [0.9, 1.1] so that x^2000 stays a normal float). Three things to keep in mind before putting a number on a slide:

1. **Small matrices reproduce the thesis**: about 2.8 µs per NumPy call against tens of ns in Nim. That is per-call overhead, not inner-loop speed, and it carries Bezanson's argument.
2. **Large matrices measure loop structure**: NumPy's `multiply.accumulate` runs along the contiguous axis, a serial chain of multiplications; a column-major version with independent elements in the inner loop is vectorised by the C compiler (packed `mulpd`). A ratio there is not a language comparison. The talk's benchmark compares the same row-by-row loops in Python and Nim for this reason.
3. **Dispatch in Nim is not free the way the thesis' Julia row is**: putting the loop in a `method` body stopped GCC from vectorising it, so a "with dispatch" row would mislead.

## The thesis beyond the case study

Useful if the slide or a deep dive wants a sentence of context on why Julia is organised the way it is.

Six chapters, and a conclusion barely two pages long. Ch. 1 catalogues 49 technical computing languages invented since Fortran and tabulates mainstream PL priorities (single dispatch, separate compilation, parametric polymorphism, static checking) against technical computing's (complex operators, inlining, ad hoc polymorphism and extensibility, experimental computing). Ch. 2 is the domain analysis the case study belongs to, including a good argument that vectorisation is a dead end. Ch. 3 is the design space. Ch. 4 is Julia's type system, subtyping algorithm, dispatch and staged programming. Ch. 5 is case studies (promotion, numeric embeddings, array indexing, linear algebra, units, JuMP, a boundary element method).

**Why dispatch gets all the attention.** It is not presented as a favourite feature but as the answer to a question about *code selection*. The thesis statement is that integrating code selection with code specialization, through type-based dynamic dispatch, meets both the performance and the productivity requirements of the domain. The argument:

- Selection is what these environments actually sell — MATLAB's `\` picking among a dozen solvers from one character — and every system reinvents a dispatch mechanism ad hoc. NumPy's `PyUFunc_Accumulate` is a hand-rolled dispatch table underneath Python's own, which is why PyPy cannot help it much.
- Selection must be late but the selected code must be early (§3.1, the "binding time dilemma"): `solve(factorize(M), x)`, where `factorize` returns `Diagonal` or `Bidiagonal` depending on the numbers. Mathematics is dependently typed; knowing a matrix is symmetric can require an arbitrary proof.
- Multiple dispatch is the fixed point of a progression, not an exotic choice (§3.3.1 refactors a wolves-and-rabbits simulation from if-chains to external multimethods, then asks why n=2 or the first argument would be special). The expression problem bites hard here because everyone works with the same few types and keeps wanting new operations on them.
- The calibration argument (§3.3.2–3.3.4): predicate dispatch and term rewriting are more powerful selection mechanisms but kill specialization or break data abstraction. The criterion is to dispatch on sets that are robust under abstract evaluation.
- Everything else is then eliminated in terms of dispatch — promotion, constructors (`Type{T}`), associated types, traits, and `@generated` staging keyed on types. The type system, `Union`, `UnionAll` and the subtyping algorithm are all downstream of that decision.

He is honest about the strain: higher-order functions do not fit (intersection-of-arrows makes ambiguity non-local and leaves no maximally-specific function type), ecosystem method ambiguities are called unfortunately common, diagonal dispatch is implemented but not formalised in subtyping, and specificity is admitted to be much less formal than subtyping.

**The angle for the talk.** Nim accepts the same diagnosis and inverts the prescription. §3.5.1's argument — that specialization is what unites parametric and ad hoc polymorphism — is equally Nim's design; the split is purely binding time. Julia bets the runtime knows the types and inference will recover them; Nim bets the programmer does, via generics, overloads, `static[T]` and concepts, with `method` as opt-in late binding. That makes the "with dispatch" column of table 2.1 a *default* in Nim rather than a fallback — and, as measured above, in Nim that column also costs vectorisation, not just a vtable lookup.

One point worth answering rather than leaving alone: §4.5 argues that type-driven staging beats macros precisely because it is semantic rather than syntactic — `@generated` gives the same result for `2+2` and `4`. Nim's typed macros and `static` parameters are a reply to that.

## Sources

- Jeff Bezanson, *Abstraction in Technical Computing*, MIT PhD thesis, 2015: <https://dspace.mit.edu/handle/1721.1/99811> (PDF also at <https://worrydream.com/refs/Bezanson_2015_-_Abstraction_in_Technical_Computing.pdf>)
- Bezanson, Edelman, Karpinski, Shah, "Julia: A Fresh Approach to Numerical Computing", SIAM Review 59(1), 2017: <https://doi.org/10.1137/141000671>
