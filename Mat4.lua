--
-- matrix.lua
--
if not BanateCore_000 then
require "000"
end

if not vec_func_included then
require "01_vec_func"
end

if not Mat_Included then
require "Mat"
end

if not Mat3_Included then
require "Mat3"
end


mat4 = ffi.typeof("double[4][4]")

-- Identity matrix for a 4x4 matrix
mat4_identity =  mat4({1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1})


function mat4_new(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
	a = a or 0
	b = b or 0
	c = c or 0
	d = d or 0

	e = e or 0
	f = f or 0
	g = g or 0
	h = h or 0

	i = i or 0
	j = j or 0
	k = k or 0
	l = l or 0

	m = m or 0
	n = n or 0
	o = o or 0
	p = p or 0

	return mat4({a,b,c,d}, {e,f,g,h}, {i,j,k,l}, {m,n,o,p})
end



local function mat4_clone(m)
	return SquareMatrix.Assign(mat4(), m, 4)
end

local function mat4_assign(a, b)
	return SquareMatrix.Assign(a, b,4)
end

local function mat4_get_col(res, m, col)
	return SquareMatrix.GetColumn(res, m, col, 4)
end

local function mat4_get_col_new(m,col)
	return mat4_get_col(vec4(), m, col)
end

local function mat4_set_col(m, col, vec)
	return SquareMatrix.SetColumn(m, col, vec, 4)
end


local function mat4_get_row(res, m, row)
	return SquareMatrix.GetRow(res, m, row, 4)
end

local function mat4_get_row_new(m, row)
	return mat4_get_row(vec4(), m, row)
end

local function mat4_set_row(m, row, vec)
	return SquareMatrix.SetRow(m, row, vec, 4)
end

-- Matrix Addition
local function mat4_add_mat4_new(a,b)
	return SquareMatrix.Add(mat4(), a, b, 4)
end

-- Matrix Subtraction
local function mat4_sub_mat4_new(a,b)
	return SquareMatrix.Sub(mat4(), a, b, 4)
end

-- Matrix Multiplication
local function mat4_mul_mat4_new(a, b)
	return SquareMatrix.Mul(mat4(), a, b, 4)
end

-- Multiply matrix by Column vector
-- MxV
-- Where
--		M == 4x4 matrix
--		V == 4x1 column matrix
--
-- MulColumn
--	0[0,0]	4[0,1]	8[0,2]	12[0,3]
--	1[1,0]	5[1,1]	9[1,2]	13[1,3]
--	2[2,0]	6[2,1]	10[2,2]	14[2,3]
--	3[3,0]	7[3,1]	11[3,2]	15[3,3]
--
function mat4_mat4_mul_vec4(res, m,v,n)
    res = res4();

    res[0] = m[0][0]*v[0] + m[0][1]*v[1] + m[0][2]*v[2] + m[0][3]*v[3];
    res[1] = m[1][0]*v[0] + m[1][1]*v[1] + m[1][2]*v[2] + m[1][3]*v[3];
    res[2] = m[2][0]*v[0] + m[2][1]*v[1] + m[2][2]*v[2] + m[2][3]*v[3];
    res[3] = m[3][0]*v[0] + m[3][1]*v[1] + m[3][2]*v[2] + m[3][3]*v[3];

    return res;
end

function mat4_mat4_mul_vec4_new(m,v,n)
	return mat4_mat4_mul_vec4(vec4(), m, v, n)
end

-- Multiply Row vector by maxtrix
-- V x M
-- Where
--		V == 1x4 row matrix
--		M == 4x4 matrix
--
-- MulRow
--
function mat4_vec4_mul_mat4(res, v,m,n)

    res[0] = m[0][0]*v[0] + m[1][0]*v[1]+ m[2][0]*v[2] + m[3][0]*v[3];
    res[1] = m[0][1]*v[0] + m[1][1]*v[1]+ m[2][1]*v[2] + m[3][1]*v[3];
    res[2] = m[0][2]*v[0] + m[1][2]*v[1]+ m[2][2]*v[2] + m[3][2]*v[3];
    res[3] = m[0][3]*v[0] + m[1][3]*v[1]+ m[2][3]*v[2] + m[3][3]*v[3];

    return res;
end

function mat4_vec4_mul_mat4_new(v,m,n)
	return mat4_vec4_mul_mat4(vec4(), v,m,n)
end




local function mat4_transpose_new(a)
	return SquareMatrix.Transpose(mat4(), a, 4)
end

local function mat4_get_diagonal_new(m)
	return SquareMatrix.GetDiagonal(vec4(), m, 4)
end





-- Get the Inverse
--	0[0,0]	4[0,1]	8[0,2]	12[0,3]
--	1[1,0]	5[1,1]	9[1,2]	13[1,3]
--	2[2,0]	6[2,1]	10[2,2]	14[2,3]
--	3[3,0]	7[3,1]	11[3,2]	15[3,3]

local function mat4_affine_inverse_new(mat)
    local result = mat4();

    -- compute upper left 3x3 matrix determinant
    local cofactor0 = mat[1][1]*mat[2][2] - mat[2][1]*mat[1][2];
    local cofactor4 = mat[2][0]*mat[1][2] - mat[1][0]*mat[2][2];
    local cofactor8 = mat[1][0]*mat[1][1] - mat[2][0]*mat[1][1];
    local det = mat[0][0]*cofactor0 + mat[0][1]*cofactor4 + mat[0][2]*cofactor8;

	if IsZero( det ) then
        assert( false ,"Matrix44::Inverse() -- singular matrix\n");
        return result;
    end

    -- create adjunct matrix and multiply by 1/det to get upper 3x3
    local invDet = 1.0/det;
    result[0][0] = invDet*cofactor0;
    result[1][0] = invDet*cofactor4;
    result[2][0] = invDet*cofactor8;

    result[0][1] = invDet*(mat[2][1]*mat[0][2] - mat[0][1]*mat[2][2]);
    result[1][1] = invDet*(mat[0][0]*mat[2][2] - mat[2][0]*mat[0][2]);
    result[2][1] = invDet*(mat[2][0]*mat[0][1] - mat[0][0]*mat[2][1]);

    result[0][2] = invDet*(mat[0][1]*mat[1][2] - mat[1][1]*mat[0][2]);
    result[1][2] = invDet*(mat[1][0]*mat[0][2] - mat[0][0]*mat[1][2]);
    result[2][2] = invDet*(mat[0][0]*mat[1][1] - mat[1][0]*mat[0][1]);

    -- multiply -translation by inverted 3x3 to get its inverse
    result[0][3] = -result[0][0]*mat[0][3] - result[0][1]*mat[1][3] - result[0][2]*mat[2][3];
    result[1][3] = -result[1][0]*mat[0][3] - result[1][1]*mat[1][3] - result[1][2]*mat[2][3];
    result[2][3] = -result[2][0]*mat[0][3] - result[2][1]*mat[1][3] - result[2][2]*mat[2][3];

	return result;
end




--[[
		TRANSFORMATION  MATRICES
--]]
-- Matrix creation
local function mat4_create_scale(res, x, y, z)
	mat4_assign(res, mat4_identity)

	res[0][0] = x
	res[1][1] = y
	res[2][2] = z

	return res
end

local function mat4_create_scale_new(x,y,z)
	return mat4_create_scale(mat4_new(), x, y, z)
end

-- Create Translation Matrix
local function mat4_create_translation(res, x, y, z)
	mat4_assign(res, mat4_identity)

	res[0][3] = x
	res[1][3] = y
	res[2][3] = z

	return res
end

local function mat4_create_translation_new(x,y,z)
	return mat4_create_translation(mat4_new(), x, y, z)
end


-- Create Rotation Matrix
local function mat4_inject_rotation_mat3(res, src)
	SquareMatrix.Assign(res, src, 3)
end


local function mat4_create_rotation(res, angle, x, y, z)
	SquareMatrix.Assign(res, mat4_identity, 4)

	local rot3 = Mat3.CreateRotation(angle, x, y, z)
	SquareMatrix.Assign(res, rot3, 3)

	return res
end

local function mat4_create_rotation_new(angle, x, y, z)
	return mat4_create_rotation(mat4_new(), angle, x, y, z)
end







function mat4_create_perspective_new(fFov, fAspect, zMin, zMax)
	local res = mat4_clone(mat4_identity)

    local yMax = zMin * math.tan(fFov * 0.5);
    local yMin = -yMax;
	local xMin = yMin * fAspect;
    local xMax = -xMin;

	res[0] = (2.0 * zMin) / (xMax - xMin);
	res[5] = (2.0 * zMin) / (yMax - yMin);
	res[8] = (xMax + xMin) / (xMax - xMin);
	res[9] = (yMax + yMin) / (yMax - yMin);
	res[10] = -((zMax + zMin) / (zMax - zMin));
	res[11] = -1.0;
	res[14] = -((2.0 * (zMax*zMin))/(zMax - zMin));
	res[15] = 0.0;

	return res
end


local function mat4_create_orthographic_new(xMin, xMax, yMin, yMax, zMin, zMax)
	local res = mat4_assign(mat4_new(), mat4_identity)

	res[0] = 2.0 / (xMax - xMin);
	res[5] = 2.0 / (yMax - yMin);
	res[10] = -2.0 / (zMax - zMin);
	res[12] = -((xMax + xMin)/(xMax - xMin));
	res[13] = -((yMax + yMin)/(yMax - yMin));
	res[14] = -((zMax + zMin)/(zMax - zMin));
	res[15] = 1.0;

	return res
end

-- Transform a Point
-- Matrix Point multiplication
-- This is a MxV multiplication where the pt
-- is a column vector
--
local function mat4_transform_pt(res, m, v)
	res[0] = m[0][0]*v[0] + m[0][1]*v[1] + m[0][2]*v[2] + m[0][3]
	res[1] = m[1][0]*v[0] + m[1][1]*v[1] + m[1][2]*v[2] + m[1][3]
	res[2] = m[2][0]*v[0] + m[2][1]*v[1] + m[2][2]*v[2] + m[2][3]

	return res
end

local function mat4_transform_pt_new(m, pt)
	return mat4_transform_pt(vec3(), m, pt)
end

-- Transform a Vector
-- Need to ignore the 'w', as it is '0' for a vector
local function mat4_transform_vec(res, m, v)
	res[0] = m[0][0]*v[0] + m[0][1]*v[1] + m[0][2]*v[2]
	res[1] = m[1][0]*v[0] + m[1][1]*v[1] + m[1][2]*v[2]
	res[2] = m[2][0]*v[0] + m[2][1]*v[1] + m[2][2]*v[2]

	return res
end

local function mat4_transform_vec_new(m, v)
	return mat4_transform_pt(vec3(), m, v)
end



local function vec4_tostring(v)
	res={}

	table.insert(res,'{')
	for col = 0,3 do
		table.insert(res,v[col])
		if col < 3 then
			table.insert(res,',')
		end
	end
	table.insert(res,'}')

	return table.concat(res)
end

local function mat4_tostring(m, roworder)
	res={}

	table.insert(res,'{')
	for row = 0,3 do
		table.insert(res,'{')
		for col = 0,3 do
			table.insert(res,m[row][col])
			if col < 3 then
				table.insert(res,',')
			end
		end
		table.insert(res,'}')
		if row < 3 then
			table.insert(res, ',\n')
		end
	end
	table.insert(res, '}')

	return table.concat(res)
end

function mat4_is_zero(m)
	return SquareMatrix.IsZero(m,4)
end


Mat4 = {
	new = mat4_new,
	Clone = mat4_clone,
	Assign = mat4_assign,
	Clean = function(m) return SquareMatrix.Clean(m,4) end,

	Identity = mat4_identity,
	GetColumn = mat4_get_col_new,
	SetColumn = mat4_set_col,

	GetRow = mat4_get_row_new,
	SetRow = mat4_set_row,

	GetDiagonal = mat4_get_diagonal_new,

	Add = mat4_add_mat4_new,
	Sub = mat4_sub_mat4_new,
	Mul = mat4_mul_mat4_new,
	PostMulColumn = mat4_mat4_mul_vec4_new,
	PreMulRow = mat4_vec4_mul_mat4_new,
	Inverse = mat4_inverse_new,
	AffineInverse = mat4_affine_inverse_new,

	CreateRotation = mat4_create_rotation_new,
	CreateRotateX = mat4_create_rotatex_new,
	CreateRotateY = mat4_create_rotatey_new,
	CreateRotateZ = mat4_create_rotatez_new,
	InjectRotationMatrix = mat4_inject_rotation_mat3,

	CreateScale = mat4_create_scale_new,
	CreateTranslation = mat4_create_translation_new,

	CreateOrthographic = mat4_create_orthographic_new,
	CreatePerspective = mat4_create_perspective_new,

	TransformPoint = mat4_transform_pt_new,
	TransformNormal = mat4_transform_vec_new,

	IsIdentity = mat_is_identity,
	IsZero = mat4_is_zero,

	vec4_tostring = vec4_tostring,
	tostring = mat4_tostring,
}
