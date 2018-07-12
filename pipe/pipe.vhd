library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity pipe is
port (
		clr,t3,c,z : in std_logic;
		sw , w : in std_logic_vector (3 downto 1);
		ir : in std_logic_vector (7 downto 4);
		ldz,ldc,cin,m,abus,drw,pcinc,lpc,lar,pcadd,arinc,selctl,memw,stop,lir,sbus,mbus,short,long: out std_logic;
		s,sel :out std_logic_vector(3 downto 0)
);
end pipe ;

architecture art of pipe is
	signal wreg,rreg,wram,rram,fi,add,sub,aand,inc,ld,st,jc,jz,jmp,stp,st0:std_logic;
begin
	wreg <= '1' when sw = "100" else '0';
	rreg <= '1' when sw = "011" else '0';
	wram <= '1' when sw = "001" else '0';
	rram <= '1' when sw = "010" else '0';
	fi <= '1' when sw = "000" else '0';
	add <= '1' when ir = "0001" else '0';
	sub <= '1' when ir = "0010" else '0';
	aand <= '1' when ir = "0011" else '0';
	inc <= '1' when ir = "0100" else '0';
	ld <= '1' when ir = "0101" else '0';
	st <= '1' when ir = "0110" else '0';
	jc <= '1' when ir = "0111" else '0';
	jz <= '1' when ir = "1000" else '0';
	jmp <= '1' when ir = "1001" else '0';
	stp <= '1' when ir = "1110" else '0';
	
	process(st0,clr,w)
	begin
		if(clr = '0')then
			st0 <= '0';
		elsif(falling_edge(t3))then
			if (w(2) = '1' and wreg = '1') or (w(1)='1' and st0 = '0' and (rram = '1' or wram = '1' or fi = '1'))then
				st0 <= not st0;
			end if;
		end if;
	end process;
   
   ldz<=((add and w(2)) or (sub and w(2)) or (aand and w(2)) or (inc and w(2))) and fi and st0;
   ldc<=((add and w(2)) or (sub and w(2)) or (inc and w(2))) and fi and st0;
   cin<=(add and w(2)) and fi and st0;
   s(3)<=((aand and w(2))or(add and w(2)) or (ld and w(2)) or (st and (w(2) or w(3))) or (jmp and w(2))) and fi and st0;
   s(2)<=((sub and w(2)) or (st and w(2)) or (jmp and w(2))) and fi and st0;
   s(1)<=((aand and w(2))or(sub and w(2)) or (ld and w(2)) or (st and (w(2) or w(3))) or (jmp and w(2))) and fi and st0;
   s(0)<=((add and w(2)) or (aand and w(2)) or (st and w(2)) or (jmp and w(2))) and fi and st0;
   m<=(((aand or ld or st or jmp) and w(2)) or (st and w(3))) and fi and st0;
   abus<=(((add or sub or aand or inc or ld or st or jmp) and w(2)) or (st and w(3))) and fi and st0;
   drw<=((((add or sub or aand or inc) and w(2)) or (ld and w(3))) and fi and st0)  or (wreg and (w(1) or w(2)));
   pcinc<= t3 and w(1) and fi and st0;
   lpc<= (jmp and w(2) and fi and st0) or (fi and (not st0) and w(1));
   lar<=((ld or st) and w(2) and fi and st0) or ((rram or wram) and (not st0) and w(1));
   pcadd<=((jc and c) or (jz and z)) and w(2) and fi and st0;
   arinc<=(rram or wram) and st0 and w(1);
   selctl <= ((wreg or rreg or rram or wram) and (w(1) or w(2))) or (fi and (not st0) and w(1));
   memw<=(st and w(3) and fi and st0) or (wram and st0 and w(1));
   stop<=(stp and w(2) and fi and st0) or ((wreg or rreg or rram or wram) and (w(1) or w(2)))or(fi and (not st0) and w(1));
   lir<=t3 and w(1) and fi and st0;
   sbus<=(wreg and (w(1) or w(2))) or (rram and (not st0) and w(1)) or (wram and w(1))or(fi and (not st0) and w(1));
   mbus<=(ld and w(3) and fi and st0) or (rram and st0 and w(1));
   short <=(rram or wram or (fi and (not st0))) and w(1);
   long<=(ld or st) and w(2) and fi and st0;
   sel(0)<=(wreg and w(1)) or (rreg and (w(1) or w(2)));
   sel(1)<=(wreg and (not st0) and w(1)) or (wreg and st0 and w(2)) or (rreg and w(2));
   sel(2)<=wreg and w(2);
   sel(3)<=(wreg and st0) or (rreg and w(2));
   -- sel <= "1111";
end art;