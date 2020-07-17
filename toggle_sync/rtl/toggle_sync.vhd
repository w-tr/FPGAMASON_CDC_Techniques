--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--   ____ ___   __    _               
--  / __// o |,'_/  .' \              
-- / _/ / _,'/ /_n / o /   _   __  _    ___  _   _  __
--/_/  /_/   |__,'/_n_/   / \,' /.' \ ,' _/,' \ / |/ /
--                       / \,' // o /_\ `./ o // || / 
--                      /_/ /_//_n_//___,'|_,'/_/|_/ 
-- 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Author      : Wesley Taylor-Rendal (WTR)
-- Syntax      : VHDL-2008
-- Description : Toggle sync is used to synchronise a pulse generating in source
--             : clock to dest clock, when source is faster.
--             : Generics explained => 
--             :    re_edge is used to capture on rising or falling edge
--             :    sync_size determines how many ff in the source domain are required.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------------------------------------------------
--
-- For when instances where clk a is fast and sig a changes faster than
-- clk_b 's rate.
--
library ieee;
use	ieee.std_logic_1164.all;

entity toggle_sync is
	generic(
		       re_edge   : boolean := true;
		       sync_size : integer := 3;
		       vec_size  : integer
	       );
	port (
		     clk_a : in  std_logic;
		     sig_a : in  std_logic_vector(vec_size-1 downto 0);
		     clk_b : in  std_logic;
		     sig_b : out std_logic_vector(vec_size-1 downto 0)
	     );
end entity toggle_sync;

architecture rtl of toggle_sync is


	signal fast_event  : std_logic_vector(vec_size-1 downto 0);
--	signal slow_event  : std_logic_vector(vec_size-1 downto 0);	
	signal q           : std_logic_vector(vec_size-1 downto 0) := (others => '0');
	type sig_b_array_t is array (sync_size-1 downto 0) of std_logic_vector(sig_b'range);
	signal capture_reg : sig_b_array_t;
begin

	-- Combinational logic
	A1: for i in sig_a'range generate
		fast_event(i) <= not q(i) when sig_a(i)='1' else q(i);
	end generate A1;

	B1: for i in sig_b'range generate
		sig_b(i) <= capture_reg(sync_size-1)(i) xor capture_reg(sync_size-2)(i);
	end generate B1;

	-- Detect toggle
	fast_clk : process (clk_a) is
	begin
		if re_edge then 
			if rising_edge(clk_a) then
				q <= fast_event;
			end if;
		else
			if falling_edge(clk_a) then
				q <= fast_event;
			end if;
		end if;

	end process;

	-- Sync the toggle to 400k domain;
	slow_clk : process(clk_b) is
	begin
		if re_edge then
			if rising_edge(clk_b) then
				capture_reg <= capture_reg(sync_size-2 downto 0) & q;
			end if;
		else
			if falling_edge(clk_b) then
				capture_reg <= capture_reg(sync_size-2 downto 0) & q;
			end if;

		end if;
	end process;

end architecture rtl;
