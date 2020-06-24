--------------------------------------------------------------------------------
--Description : When multi bit signals are synchronised with 2FF_sync each bit 
--				is synchronised seperately. Normally under these conditions the
--              metastability is resolved in the first FF, which can move to '1'
--              or '0'. This however becomes a problem when dealing with a 
--				std_logic_vector because of data incoherency. For a 2FF_sync to 
--				work on a parallel word, one must ensure only one bit changes at
--				any given clk cyle. ERGO we need gray encoding.

library ieee;
use ieee.std_logic_1164.all;


entity gray_encode_cdc is
	port
	(
		clk : in std_logic;
		rst : in std_logic;
		siga: in std_logic_vector;
		sigb: out std_logic_vector

	);
end entity gray_encode_cdc;

architecture rtl of gray_encode_cdc is

	function bin2gray(bin : std_logic_vector) return std_logic_vector is
		variable gray : std_logic_vector(bin'range);
	begin 
		for i in bin'range loop
			if i = bin'high then
				gray(i) := bin(i);
			else 
				gray(i) := bin(i) xor bin(i+1);
			end if;
		end for;
		return gray;
	end function;

	function gray2bin(gray : std_logic_vector) return std_logic_vector is
		variable bin : std_logic_vector(gray'range);
		for i in gray'range loop
			if i = gray'high then
				bin(i) := gray(i);
			else
				bin(i) := gray(i) xor bin(i+1);
			end if;
		end loop;
		return bin;
	end function;

	signal siga_d : std_logic_vector(siga'range);
	signal sigb_q : std_logic_vector(sigb'range);

begin

	siga_d <= bin2gray(siga);

	x : for i in siga'range generate
		u_ff_sync : ff_sync
		port map
		(
			clka => clka,
			clkb => clkb,
			siga => siga_d(i),
			sigb => sigb_q(i)
		);
	end generate;

	sigb <= gray2bin(sigb_q);

end architecture;
