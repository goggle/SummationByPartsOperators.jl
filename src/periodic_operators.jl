
"""
    PeriodicDerivativeCoefficients{T,StencilWidth,Parallel}

The coefficients of a derivative operator on a periodic grid.
"""
struct PeriodicDerivativeCoefficients{T,LowerOffset,UpperOffset,Parallel} <: AbstractDerivativeCoefficients{T}
    # coefficients defining the operator and its action
    lower_coef::SVector{LowerOffset, T}
    central_coef::T
    upper_coef::SVector{UpperOffset, T}
    parallel::Parallel
    # corresponding orders etc.
    derivative_order::Int
    accuracy_order  ::Int
    symmetric       ::Bool

    function PeriodicDerivativeCoefficients(lower_coef::SVector{LowerOffset, T}, central_coef::T, upper_coef::SVector{UpperOffset, T}, parallel::Parallel, derivative_order::Int, accuracy_order::Int) where {T,LowerOffset,UpperOffset,Parallel}
        symmetric = LowerOffset == UpperOffset
        if symmetric
            @inbounds for i in Base.OneTo(LowerOffset)
                symmetric = symmetric && lower_coef[i] == upper_coef[i]
            end
        end
        new{T,LowerOffset,UpperOffset,Parallel}(lower_coef, central_coef, upper_coef, parallel, derivative_order, accuracy_order, symmetric)
    end
end

derivative_order(coefficients::AbstractDerivativeCoefficients) = coefficients.derivative_order
accuracy_order(coefficients::AbstractDerivativeCoefficients) = coefficients.accuracy_order
Base.eltype(coefficients::AbstractDerivativeCoefficients{T}) where {T} = T
Base.issymmetric(coefficients::AbstractDerivativeCoefficients) = coefficients.symmetric

function Base.A_mul_B!(dest, coefficients::PeriodicDerivativeCoefficients, u)
    mul!(dest, coefficients, u, one(eltype(dest)), zero(eltype(dest)))
end

function *(coefficients::AbstractDerivativeCoefficients, u::AbstractVector)
    T = promote_type(eltype(coefficients), eltype(u))
    dest = similar(u, T)
    A_mul_B!(dest, coefficients, u)
    dest
end

"""
    mul!(dest::AbstractVector, coefficients::PeriodicDerivativeCoefficients, u::AbstractVector, α, β)

Compute `α*D*u + β*dest` and store the result in `dest`.
"""
function mul!(dest::AbstractVector, coefficients::PeriodicDerivativeCoefficients{T,LowerOffset,UpperOffset}, u::AbstractVector, α, β) where {T,LowerOffset,UpperOffset}
    @boundscheck begin
        @argcheck length(dest) == length(u) DimensionMismatch
        @argcheck length(u) > LowerOffset+UpperOffset DimensionMismatch
    end

    @unpack lower_coef, central_coef, upper_coef, parallel = coefficients
    convolve_periodic_boundary_coefficients!(dest, lower_coef, central_coef, upper_coef, u, α, β)
    convolve_interior_coefficients!(dest, lower_coef, central_coef, upper_coef, u, α, β, parallel)
end


@generated function convolve_periodic_boundary_coefficients!(dest::AbstractVector, lower_coef::SVector{LowerOffset}, central_coef, upper_coef::SVector{UpperOffset}, u::AbstractVector, α, β) where {LowerOffset, UpperOffset}
    ex_lower = :( nothing )
    for i in 1:LowerOffset
        ex = :( lower_coef[$LowerOffset]*u[end-$(LowerOffset-i)] )
        for j in LowerOffset-1:-1:1
            if i-j < 1
                ex = :( $ex + lower_coef[$j]*u[end-$(j-i)] )
            else
                ex = :( $(ex) + lower_coef[$j]*u[$(i-j)] )
            end
        end
        ex = :( $ex + central_coef*u[$i] )
        for j in 1:UpperOffset
            ex = :( $ex + upper_coef[$j]*u[$(i+j)] )
        end
        ex_lower = quote
            $ex_lower
            @inbounds dest[$i] = β*dest[$i] + α*$ex
        end
    end

    ex_upper = :( nothing )
    for i in (UpperOffset-1):-1:0
        ex = :( lower_coef[$LowerOffset]*u[end-$(i+LowerOffset)] )
        for j in LowerOffset-1:-1:1
            ex = :( $ex + lower_coef[$j]*u[end-$(j+i)] )
        end
        ex = :( $ex + central_coef*u[end-$i] )
        for j in 1:UpperOffset
            if i-j < 0
                ex = :( $ex + upper_coef[$j]*u[$(j-i)] )
            else
                ex = :( $ex + upper_coef[$j]*u[end-$(i-j)] )
            end
        end
        ex_upper = quote
            $ex_upper
            @inbounds dest[end-$i] = β*dest[end-$i] + α*$ex
        end
    end

    quote
        $ex_lower
        $ex_upper
    end
end


@generated function convolve_interior_coefficients!(dest::AbstractVector, lower_coef::SVector{LowerOffset}, central_coef, upper_coef::SVector{UpperOffset}, u::AbstractVector, α, β, parallel) where {LowerOffset, UpperOffset}
    ex = :( lower_coef[$LowerOffset]*u[i-$LowerOffset] )
    for j in LowerOffset-1:-1:1
        ex = :( $ex + lower_coef[$j]*u[i-$j] )
    end
    ex = :( $ex + central_coef*u[i] )
    for j in 1:UpperOffset
        ex = :( $ex + upper_coef[$j]*u[i+$j] )
    end

    quote
        @inbounds for i in $(LowerOffset+1):(length(dest)-$UpperOffset)
            dest[i] = β*dest[i] + α*$ex
        end
    end
end

function convolve_interior_coefficients!(dest::AbstractVector{T}, lower_coef::SVector{LowerOffset}, central_coef, upper_coef::SVector{UpperOffset}, u::AbstractVector, α, β, parallel::Val{:threads}) where {T, LowerOffset, UpperOffset}
    Threads.@threads for i in (LowerOffset+1):(length(dest)-UpperOffset) @inbounds begin
        tmp = zero(T)
        for j in Base.OneTo(LowerOffset)
            tmp += lower_coef[j]*u[i-j]
        end
        tmp += central_coef*u[i]
        for j in Base.OneTo(UpperOffset)
            tmp += upper_coef[j]*u[i+j]
        end
        dest[i] = β*dest[i] + α*tmp
    end end
end


"""
    periodic_central_derivative_coefficients(derivative_order, accuracy_order, T=Float64, parallel=Val{:serial}())

Create the `PeriodicDerivativeCoefficients` approximating the `derivative_order`-th
derivative with an order of accuracy `accuracy_order` and scalar type `T`.
The evaluation of the derivative can be parallised using threads by chosing
`parallel=Val{:threads}())`.
"""
function periodic_central_derivative_coefficients(derivative_order, accuracy_order, T=Float64, parallel=Val{:serial}())
    @argcheck derivative_order > 0
    @argcheck accuracy_order > 0
    @argcheck typeof(parallel) <: Union{Val{:serial}, Val{:threads}}

    if isodd(accuracy_order)
        warn("Central derivative operators support only even orders of accuracy.")
    end

    if derivative_order == 1
        # Exact evaluation of the coefficients, see
        # Beljadid, LeFloch, Mishra, Parés (2017)
        # Schemes with Well-Controlled Dissipation. Hyperbolic Systems in Nonconservative Form.
        # Communications in Computational Physics 21.4, pp. 913-946.
        n = (accuracy_order+1) ÷ 2
        coef = Vector{T}(n)
        for j in 1:n
            tmp = one(Rational{Int128})
            if iseven(j)
                tmp *= -1
            end
            for i in 1:j
                tmp *= (n+1-i) // (n+i)
            end
            coef[j] =  tmp / j
        end
        upper_coef = SVector{n,T}(coef)
        central_coef = zero(T)
        lower_coef = -upper_coef
    elseif derivative_order == 2
        # Exact evaluation of the coefficients, see
        # Beljadid, LeFloch, Mishra, Parés (2017)
        # Schemes with Well-Controlled Dissipation. Hyperbolic Systems in Nonconservative Form.
        # Communications in Computational Physics 21.4, pp. 913-946.
        n = (accuracy_order+1) ÷ 2
        coef = Vector{T}(n)
        for j in 1:n
            tmp = one(Rational{Int128})
            if iseven(j)
                tmp *= -1
            end
            for i in 1:j
                tmp *= (n+1-i) // (n+i)
            end
            coef[j] =  2*tmp / j^2
        end
        upper_coef = SVector{n,T}(coef)
        central_coef = -2*sum(upper_coef)
        lower_coef = upper_coef
    elseif derivative_order == 3
        # Exact evaluation of the coefficients, see
        # Beljadid, LeFloch, Mishra, Parés (2017)
        # Schemes with Well-Controlled Dissipation. Hyperbolic Systems in Nonconservative Form.
        # Communications in Computational Physics 21.4, pp. 913-946.
        n = (accuracy_order+1) ÷ 2
        coef = Vector{T}(n)
        for j in 1:n
            tmp = one(Rational{Int128})
            if isodd(j)
                tmp *= -1
            end
            for i in 1:j
                tmp *= (n+1-i) // (n+i)
            end
            fac = zero(Rational{Int128})
            for k in 1:n
                k == j && continue
                fac += 1 // k^2
            end
            coef[j] =  6*tmp*fac/ j
        end
        upper_coef = SVector{n,T}(coef)
        central_coef = zero(T)
        lower_coef = -upper_coef
    else
        throw(ArgumentError("Derivative order $derivative_order not implemented yet."))
    end

    PeriodicDerivativeCoefficients(lower_coef, central_coef, upper_coef, parallel, derivative_order, accuracy_order)
end

"""
    fornberg(x::Vector{T}, m::Int) where {T}

Calculate the weights of a finite difference approximation of the `m`th derivative
with maximal order of accuracy at `0` using the nodes `x`, see
Fornberg (1998)
Calculation of Weights in Finite Difference Formulas
SIAM Rev. 40.3, pp. 685-691.
"""
function fornberg(xx::Vector{T}, m::Int) where {T}
    x = sort(xx)
    @argcheck x[1] <= 0
    @argcheck x[end] >= 0
    @argcheck length(unique(x)) == length(x)
    @argcheck zero(T) in x
    @argcheck m >= 1

    z = zero(T)
    n = length(x) - 1
    c = zeros(T, length(x), m+1)
    c1 = one(T)
    c4 = x[1] - z
    c[1,1] = one(T)
    for i in 1:n
        mn = min(i,m)
        c2 = one(T)
        c5 = c4
        c4 = x[i+1] - z
        for j in 0:i-1
            c3 = x[i+1] - x[j+1]
            c2 = c2 * c3
            if j == i-1
                for k in mn:-1:1
                    c[i+1,k+1] = c1 * (k*c[i,k]-c5*c[i,k+1]) / c2
                end
                c[i+1,1] = -c1*c5*c[i,1] / c2
            end
            for k in mn:-1:1
                c[j+1,k+1] = (c4*c[j+1,k+1]-k*c[j+1,k]) / c3
            end
            c[j+1,1] = c4*c[j+1,1] / c3
        end
        c1 = c2
    end

    c[:,end]
end

"""
    function periodic_derivative_coefficients(derivative_order, accuracy_order, left_offset=-(accuracy_order+1)÷2, T=Float64, parallel=Val{:serial}())

Create the `PeriodicDerivativeCoefficients` approximating the `derivative_order`-th
derivative with an order of accuracy `accuracy_order` and scalar type `T` where
the leftmost grid point used is determined by `left_offset`.
The evaluation of the derivative can be parallised using threads by chosing
parallel=Val{:threads}())`.
"""
function periodic_derivative_coefficients(derivative_order, accuracy_order, left_offset=-(accuracy_order+1)÷2, T=Float64, parallel=Val{:serial}())
    @argcheck -accuracy_order <= left_offset <= 0

    x = Rational{Int128}.(left_offset:left_offset+accuracy_order)
    c = fornberg(x, derivative_order)

    z = zero(eltype(x))
    lower_idx = x .< z
    central_idx = first(find(xx->xx==z, x))
    upper_idx = x .> z

    LowerOffset = sum(lower_idx)
    UpperOffset = sum(upper_idx)

    lower_coef = SVector{LowerOffset, T}(reverse(c[lower_idx]))
    central_coef = T(c[central_idx])
    upper_coef = SVector{UpperOffset, T}(c[upper_idx])

    PeriodicDerivativeCoefficients(lower_coef, central_coef, upper_coef, parallel, derivative_order, accuracy_order)
end


"""
    PeriodicDerivativeOperator{T,StencilWidth,Parallel}

A derivative operator on a uniform periodic grid with grid spacing `Δx`.
"""
struct PeriodicDerivativeOperator{T,LowerOffset,UpperOffset,Parallel} <: AbstractDerivativeOperator{T}
    coefficients::PeriodicDerivativeCoefficients{T,LowerOffset,UpperOffset,Parallel}
    Δx::T
    factor::T

    function PeriodicDerivativeOperator(coefficients::PeriodicDerivativeCoefficients{T,LowerOffset,UpperOffset,Parallel}, Δx::T) where {T,LowerOffset,UpperOffset,Parallel}
        factor = inv(Δx^coefficients.derivative_order)
        new{T,LowerOffset,UpperOffset,Parallel}(coefficients, Δx, factor)
    end
end

derivative_order(D::AbstractDerivativeOperator) = derivative_order(D.coefficients)
accuracy_order(D::AbstractDerivativeOperator) = accuracy_order(D.coefficients)
Base.eltype(D::AbstractDerivativeOperator{T}) where {T} = T
Base.issymmetric(D::AbstractDerivativeOperator) = issymmetric(D.coefficients)


function Base.A_mul_B!(dest, D::PeriodicDerivativeOperator, u)
    mul!(dest, D, u, one(eltype(dest)), zero(eltype(dest)))
end

function *(D::PeriodicDerivativeOperator, u)
    T = promote_type(eltype(D), eltype(u))
    dest = similar(u, T)
    A_mul_B!(dest, D, u)
    dest
end

"""
    mul!(dest::AbstractVector, D::PeriodicDerivativeOperator, u::AbstractVector, α, β)

Compute `α*D*u + β*dest` and store the result in `dest`.
"""
Base.@propagate_inbounds function mul!(dest::AbstractVector, D::PeriodicDerivativeOperator, u::AbstractVector, α, β)
    mul!(dest, D.coefficients, u, α*D.factor, β)
end


"""
    periodic_central_derivative_operator(Δx, derivative_order, accuracy_order, parallel=Val{:serial}())

Create a `PeriodicDerivativeOperator` approximating the `derivative_order`-th
derivative on a uniform grid with spacing `Δx` up to order of accuracy
`accuracy_order`.
The evaluation of the derivative can be parallised using threads by chosing
`parallel=Val{:threads}())`.
"""
function periodic_central_derivative_operator(Δx, derivative_order, accuracy_order, parallel=Val{:serial}())
    coefficients = periodic_central_derivative_coefficients(derivative_order, accuracy_order, typeof(Δx), parallel)
    PeriodicDerivativeOperator(coefficients, Δx)
end

"""
    periodic_central_derivative_operator(Δx, derivative_order, accuracy_order, parallel=Val{:serial}())

Create a `PeriodicDerivativeOperator` approximating the `derivative_order`-th
derivative on a uniform grid with spacing `Δx` up to order of accuracy
`accuracy_order` where the leftmost grid point used is determined by `left_offset`.
The evaluation of the derivative can be parallised using threads by chosing
`parallel=Val{:threads}())`.
"""
function periodic_derivative_operator(Δx, derivative_order, accuracy_order, left_offset=-(accuracy_order+1)÷2, parallel=Val{:serial}())
    coefficients = periodic_derivative_coefficients(derivative_order, accuracy_order, left_offset, typeof(Δx), parallel)
    PeriodicDerivativeOperator(coefficients, Δx)
end