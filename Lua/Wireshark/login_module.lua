
login_module = {}

local login_proto = Proto("login", "Login")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_login_type = {
	[1] = "Login Request",
	[2] = "Login Response",
	[3] = "Logout Request",
	[4] = "Logout Response",
	[5] = "Disconnect Notify",
}
local arr_login_enc_type = {
	[1] = "No Encryption",
	[2] = "MD5",
	[3] = "Consult", --协商加密
	[4] = "DES",
}
local arr_login_result = {
	[0] = "Success",
	[1] = "Unauthorized",
	[2] = "Authorize Fail",
}

-- login
local login_type = ProtoField.uint32("login.type", "Type", base.UNIT_STRING, arr_login_type)
local login_sessionid = ProtoField.uint16("login.sessionid", "Session ID", base.DEC)
local login_enc_type = ProtoField.uint16("login.enc_type", "Encryption Type", base.DEC, arr_login_enc_type)
local login_username = ProtoField.string("login.username", "User Name", base.ASCII)
local login_passwd = ProtoField.bytes("login.passwd", "Password", base.NONE)
local login_expired = ProtoField.uint32("login.expired", "Expired", base.DEC)
local login_hb_timeout = ProtoField.uint32("login.hb_timeout", "HeartBeat Timeout", base.DEC)
local login_result = ProtoField.uint32("login.result", "Result", base.UNIT_STRING, arr_login_result)
local login_enc_data = ProtoField.bytes("login.enc_data", "Encryption Data", base.none)

-- for test parameters
local login_test = ProtoField.uint32("login.test", "Test", base.HEX)

-- 将字段添加都协议中
login_proto.fields = {
	login_type,
	login_sessionid,
	login_enc_type,
	login_username,
	login_passwd,
	login_expired,
	login_hb_timeout,
	--login resp
	login_result,
	login_enc_data,
}

local data_dis = Dissector.get("data")

function login_request(tvb, pinfo, login_tree)
	local offset = 0
	login_tree:add(login_type, tvb:range(offset, 4))
	offset = offset + 4
	login_tree:add(login_sessionid, tvb:range(offset, 2))
	offset = offset + 2
	login_tree:add(login_enc_type, tvb:range(offset, 2))
	offset = offset + 2
	login_tree:add(login_username, tvb:range(offset, 64))
	offset = offset + 64
	login_tree:add(login_passwd, tvb:range(offset, 64))
	offset = offset + 64
	login_tree:add(login_expired, tvb:range(offset, 4))
	offset = offset + 4
	login_tree:add(login_hb_timeout, tvb:range(offset, 4))
	offset = offset + 4
	return offset
end

function login_response(tvb, pinfo, login_tree)
	local offset = 0
	login_tree:add(login_type, tvb:range(offset, 4))
	offset = offset + 4
	login_tree:add(login_result, tvb:range(offset, 4))
	offset = offset + 4
	login_tree:add(login_sessionid, tvb:range(offset, 2))
	offset = offset + 2
	login_tree:add(login_enc_type, tvb:range(offset, 2))
	offset = offset + 2
	login_tree:add(login_expired, tvb:range(offset, 4))
	offset = offset + 4
	login_tree:add(login_enc_data, tvb:range(offset, 64))
	offset = offset + 64
	return offset
end

function logout_request(tvb, pinfo, login_tree)
	local offset = 0
	login_tree:add(login_type, tvb:range(offset, 4))
	offset = offset + 4
	return offset
end
function logout_response(tvb, pinfo, login_tree)
	local offset = 0
	login_tree:add(login_type, tvb:range(offset, 4))
	offset = offset + 4
	return offset
end
function disconnect_notify(tvb, pinfo, login_tree)
	local offset = 0
	login_tree:add(login_type, tvb:range(offset, 4))
	offset = offset + 4
	return offset
end
function login_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local login_tree = treeitem:add(login_proto, tvb:range(offset))
	local login_type_tmp = tvb:range(offset, 4):uint()
	if (login_type_tmp == 1) then
		pinfo.cols.info:set("<GSSP> <Login Request>")
		offset = login_request(tvb, pinfo, login_tree)
	elseif (login_type_tmp == 2) then
		pinfo.cols.info:set("<GSSP> <Login Response>")
		offset = login_response(tvb, pinfo, login_tree)
	elseif (login_type_tmp == 3) then
		pinfo.cols.info:set("<GSSP> <Logout Request>")
		offset = logout_request(tvb, pinfo, login_tree)
	elseif (login_type_tmp == 4) then
		pinfo.cols.info:set("<GSSP> <Logout Response>")
		offset = logout_response(tvb, pinfo, login_tree)
	elseif (login_type_tmp == 5) then
		pinfo.cols.info:set("<GSSP> <Disconnect Notify>")
		offset = disconnect_notify(tvb, pinfo, login_tree)
	end
	
	data_dis:call(tvb:range(offset):tvb(), pinfo, treeitem)
	return offset
end
