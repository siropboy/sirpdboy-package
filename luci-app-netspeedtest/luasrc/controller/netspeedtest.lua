
module("luci.controller.netspeedtest", package.seeall)

function index()
	local uci = require("luci.model.uci").cursor()
	local page
	page = entry({"admin", "network", "netspeedtest"}, template("netspeedtest"), "netspeedtest", 90)
	page.dependent = true
	
	page = entry({"admin", "network", "diag_iperf"}, call("diag_iperf"), nil)
	page.leaf = true

	page = entry({"admin", "network", "diag_iperf6"}, call("diag_iperf6"), nil)
	page.leaf = true
	page = entry({"admin", "network","diag_ping"}, call("diag_ping"), nil)
	page.leaf = true	
	page = entry({"admin", "network","diag_ping6"}, call("diag_ping6"), nil)
	page.leaf = true
end

function diag_cmd(cmd, addr)
	if addr and addr:match("^[a-zA-Z0-9%-%.:_]+$") then
		luci.http.prepare_content("text/plain")

		local util = io.popen(cmd % luci.util.shellquote(addr))
		if util then
			while true do
				local ln = util:read("*l")
				if not ln then break end
				luci.http.write(ln)
				luci.http.write("\n")
			end

			util:close()
		end

		return
	end

	luci.http.status(500, "Bad address")
end

function testlan(cmd)
		luci.http.prepare_content("text/plain")

		local util = io.popen(cmd)
		if util then
			while true do
				local ln = util:read("*l")
				if not ln then break end
				luci.http.write(ln)
				luci.http.write("\n")
			end

			util:close()
		end

		return

end


function diag_iperf(addr)
	testlan("iperf3 -s 2>&1")
end

function diag_iperf6(addr)
	testlan("iperf3 -s -B 0.0.0.0 2>&1")
end

function diag_ping(addr)
	diag_cmd("ping -c 5 -W 1 %s 2>&1", addr)
end

function diag_ping6(addr)
	diag_cmd("ping6 -c 5 %s 2>&1", addr)
end
