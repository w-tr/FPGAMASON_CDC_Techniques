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

	---- sync the reset to emmc_clk_sel
	--vari_clk : process(emmc_clk_s) is 
	--begin
	--	if rising_edge(emmc_clk_s) then
	--		if emmc_clk_locked = '0' then  
	--			hw_rst_wt_cmpl <= '0';
	--		else
	--			hw_rst_wt_cmpl <= rst_wt_complete_int;
	--		end if;
	--	end if;
	--end process;
end architecture rtl;


--------------------------------------------------------------------------------
library ieee;
use	ieee.std_logic_1164.all;

library cdc_sync_lib;

entity toggle_sync_tb is

	end entity toggle_sync_tb;

architecture tb of toggle_sync_tb is


	constant vec_size : integer := 4;
	constant clk_a_period : time := 25 ns;
	constant clk_b_period : time := 150 ns;
	signal clk_a :  std_logic;
	signal sig_a :  std_logic_vector(vec_size-1 downto 0);
	signal clk_b :  std_logic;
	signal sig_b :  std_logic_vector(vec_size-1 downto 0);
	signal sig_a2:  std_logic;
	signal sig_b2:  std_logic;

begin



	uut : entity cdc_sync_lib.toggle_sync 
	generic map(
		       re_edge   => true,
		       sync_size => 3,
		       vec_size  => 4
	       )
	port map(
		     clk_a => clk_a,
		     sig_a => sig_a,
		     clk_b => clk_b,
		     sig_b => sig_b
	     );
	uut2 : entity cdc_sync_lib.toggle_sync 
	generic map(
		       re_edge   => true,
		       sync_size => 3,
		       vec_size  => 1
	       )
	port map(
		     clk_a => clk_a,
		     sig_a(0) => sig_a2,
		     clk_b => clk_b,
		     sig_b(0) => sig_b2
	     );

	gen_clk_a : process 
	begin
		clk_a <= '1';
		wait for clk_a_period/2;
		clk_a <= '0';
		wait for clk_a_period/2;
	end process;
	gen_clk_b : process 
	begin
		clk_b <= '1';
		wait for clk_b_period/2;
		clk_b <= '0';
		wait for clk_b_period/2;
	end process;
	stimulus : process
	begin
		sig_a <= X"0";
		sig_a2 <= '0';

		for i in 1 to 100 loop
			wait until rising_edge(clk_a);
		end loop;

		sig_a <= x"4";
		sig_a2 <= '1';

		for i in 1 to 1 loop
			wait until rising_edge(clk_a);
		end loop;
		sig_a <= x"0";
		sig_a2 <= '0';
		for i in 1 to 1000 loop
			wait until rising_edge(clk_a);
		end loop;

		sig_a <= x"6";
		sig_a2 <= '1';

		for i in 1 to 1 loop
			wait until rising_edge(clk_a);
		end loop;
		sig_a <= x"0";
		sig_a2 <= '0';
		for i in 1 to 1000 loop
			wait until rising_edge(clk_a);
		end loop;

		report "End of simulation" severity failure; -- force sim termination
		wait;
	end process;
end architecture tb;
