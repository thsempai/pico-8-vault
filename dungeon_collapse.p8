pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
function _init()
	chck=chunck()
	r=chck:wfc()
	
	while r~=1do
		r=chck:wfc()
	end	
end

function _draw()
	cls(0)
	for x=0,15 do
	 for y=0,15 do
	 	v=chck:get(x,y):value()
	 	tilesdata[v]:spr(x,y)
	 end
	end
end
-->8
--wave function collapse
function restr(dx,dy)
	r={dx,dy,tiles={}}	
	
	function r.add(s,t)
		if type(t) == "table" then
			for v in all(t) do s:add(v) end
		end
		for v in all(s.tiles) do
			if v==t then return end 
		end
		add(s.tiles,t)
	end
	
	function r.remove(s,t)
		if type(t) == "table" then
			for v in all(t) do s:remove(v) end
		end
		del(s.tiles,t)
	end
	
	function r.addall(s)
		for k,_ in pairs(tiles) do
			s:add(k)
		end
	end
	
	function r.reset(s)
 		s.tiles={}
	end
	
	return r
	
end

function restrg()
	
	r={g={}}
	
	function r.get(s,dx,ddy)
		if r.g[x]==nil then return nil end
		return r.g[dx][dy]
	end

	function r.set(s,dx,dy,v)

		if r.g[dx]==nil then
			r.g[dx]={}
		end
		r.g[dx][dy]=v
	end

	
	function r.add(s,dx,dy,v)
		rt=s:get(dx,dy)
		if rt==nil then
			rt=restr(dx,dy)
		end
		rt:add(v)
	end
	
	function r.remove(s,dx,dy,v)
	rt=s:get(dx,dy)
		if rt~=nil then
			rt:remove(v)
		end
	end
	
	function r.addall(s,dx,dy)
		rt=s:get(dx,dy)
		if rt~=nil then
			rt:addall()
		end
	end
	
	function r.addarr(s,v,r)
		r=r or 1
		for dx=-r,r do
			for dy=-r,r do
				if dx~=0 or dy~=0 then
					if v then
						s:add(dx,dy,v)
					else
						s:addall(dx,dy)
					end
				end
			end
		end
	end
	
	function r.removearr(s,v,r)
		r=r or 1
		for dx=-r,r do
			for dy=-r,r do
				if dx~=0 or dy~=0 then
					if v then
						s:remove(dx,dy,v)
					else
						s:reset(dx,dy)
					end
				end
			end
		end
	end
	
	function r.reset(s,dx,dy)
		rt=s:get(dx,dy)
		if rt~=nil then
			rt:reset()
		end
	end
	
	return r
end

function tiled(sp,fx,fy)
	t={sp=sp,fx=fx,fy=fy,rg=restrg()}
	
	function t.spr(s,x,y)
		spr(s.sp,x*8,y*8,1,1,fx,fy)
	end
	
	return t
end

function tilec(x,y)
	t={x=x,y=y,pool={}}
	
	function t.addall(s)
		for k,_ in pairs(tilesdata) do
			add(s.pool,k)
		end
	end
	
	function t.addr(s,r)
		np = {}
		for v in all(s.pool) do
			for vr in all(r) do
				if v==vr then
					add(np,v)
				end
			end
		end
		s.pool=np
	end
	
	function t.choose(s)
		v = rnd(s.pool)
		s.pool={v}
	end
	
	function t.check(s)
		if #s.pool==0then return-1end
		if #s.pool==1then return 1end
		return 0
	end
	
	function t.count(s)
		return #s.pool
	end
	
	function t.value(s)
		if #s.pool>1 then return 'undefined'end
		if #s.pool==0 then return 'impossible'end
		return s.pool[1]
	end
	
	return t
end

function chunck(w,h)
	c={w=w or 16,h=h or 16,data={}}
	
	for x=0,c.w-1do 
		c.data[x]={}
		for y=0,c.h-1do
			c.data[x][y]=tilec(x,y)
			c.data[x][y]:addall()
		end 
	end
	
	function c.get(s,x,y)
		if s.data[x]==nil then return nil end
		return s.data[x][y]
	end

	function c.set(s,x,y,v)
		if s.data[x]~=nil then
			s.data[x][y]=v
		end
	end
	
	function c.check(s)
		r=1
		for x=0,s.w-1do for y=0,s.h-1do			
			c=s:get(x,y):check()
			if c==-1then return-1end
			if	r==1 and c==0 then r=0end
		end end
		return r
	end
	
	function c.gettiles(s)
		t={}
		for x=0,s.w-1do for y=0,s.h-1do
			cnt=s:get(x,y):count()
			if cnt~=1 then
				if #t==0 or cnt<t[1]:count() then
					t={s:get(x,y)}
				elseif cnt==t[1]:count() then
					add(t,s:get(x,y))
				end
			end
		end end
		return t
	end
	
	function c.wfc(s)
		c=s:check()
		while c==0 do
			gt=s:gettiles()
			t=rnd(gt)
			t:choose()
			-- collapse here
			c=s:check()
		end
		return c
	end
	
	function applyrules(s)
		for x=0,s.w-1do for y=0,s.h-1do
		-- here	
		end end
	end
	
	return c
end
-->8
--data
tilesdata={}
tilesdata.none=tiled(0)
tilesdata.floor=tiled(1)
tilesdata.wall_v=tiled(2)
tilesdata.wall_h=tiled(3)
tilesdata.corner_nw=tiled(4)
tilesdata.corner_ne=tiled(4,true)
tilesdata.corner_sw=tiled(4,false,true)
tilesdata.corner_se=tiled(4,true,true)

tilesdata.none.rg:addarr()
tilesdata.none.rg:removearr("floor")

tilesdata.floor.rg:addarr()
tilesdata.floor.rg:removearr("none")

tilesdata.wall_v.rg:addarr()
tilesdata.wall_h.rg:addarr()
tilesdata.corner_nw.rg:addarr()
tilesdata.corner_ne.rg:addarr()
tilesdata.corner_sw.rg:addarr()
tilesdata.corner_se.rg:addarr()

__gfx__
00000000666666665555666666666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666666666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666666666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666666666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666655555555555566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666655555555555566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666655555555555566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665555666655555555555566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
