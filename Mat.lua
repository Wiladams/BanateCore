Mat_Included = true

if not vec_func_included then
require "01_vec_func"
end

local function mat_assign(a, b, n)
	for row=0,n-1 do
		for col =0,n-1 do
			a[row][col] = b[row][col]
		end
	end

	return a
end

local function mat_clean(a, n)
	for row=0,n-1 do
		for col =0,n-1 do
			a[row][col] = 0
		end
	end

	return a
end

local function mat_is_zero(m, n)
	for row=0,n-1 do
		for col=0,n-1 do
			if not IsZero(m[row][col]) then
				return false
			end
		end
	end
end

local function mat_get_col(res, m, col, n)
	for i=0,n-1 do
		res[i] = m[i][col]
	end

	return res
end

local function mat_set_col(m, col, vec, n)
	for i=0,n-1 do
		m[i][col] = vec[i]
	end

	return m
end

local function mat_get_row(res, m, row, n)
	for i=0,n-1 do
		res[i] = m[row][i]
	end
	return res
end

local function mat_set_row(m, row, vec, n)
	for i=0,n-1 do
		m[row][i] = vec[i]
	end

	return m
end

local function mat_get_diagonal(res, m, n)
	for i=0,n-1 do
		res[i] = m[i][i]
	end

	return res
end

function mat_transpose(res, a, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = a[col][row]
		end
	end
	return res
end

function mat_add_mat(res, a, b, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = a[row][col] + b[row][col]
		end
	end
	return res
end

function mat_sub_mat(res, a, b, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = a[row][col] - b[row][col]
		end
	end
	return res
end

function mat_mul_mat(res, a, b, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = 0
			for k=0,n-1 do
				res[row][col] = res[row][col] + a[row][k]*b[k][col]
			end
		end
	end

	return res
end

function mat_scale_s(res, a, s, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = a[row][col] * s
		end
	end
	return res
end

function mat_scale(res, a, b, n)
	for row=0,n-1 do
		for col=0,n-1 do
			res[row][col] = a[row][col] * b[row][col]
		end
	end
	return res
end

SquareMatrix = {
	Assign = mat_assign,
	Clean = mat_clean,

	GetColumn = mat_get_col,
	GetDiagonal = mat_get_diagonal,
	GetRow = mat_get_row,

	SetColumn = mat_set_col,
	SetRow = mat_set_row,

	Add = mat_add_mat,
	Sub = mat_sub_mat,
	Mul = mat_mul_mat,
	Scale = mat_scale,
	ScaleS = mat_scale_s,

	Transpose = mat_transpose,

	IsIdentity = mat_is_identity,
	IsZero = mat_is_zero,
}
