--
-- For when clocks are asynchronous to each other but events last multiple clocks
-- in the clock domain being synched to.
-- Often used to combat metastability.
-- If you can't verify on a vhdl-2008 platform then use alternative for generate statement
--
library ieee;
use	ieee.std_logic_1164.all;

entity ff_sync is
	generic(
		       pre_reg   : boolean := false;
		       re_edge   : boolean := true;
		       sync_size : integer := 2;
		       vec_size  : integer
	       );
	port (
		     clk_a : in  std_logic;
		     sig_a : in  std_logic_vector(vec_size-1 downto 0);
		     clk_b : in  std_logic;
		     sig_b : out std_logic_vector(vec_size-1 downto 0)
	     );
end entity ff_sync;


architecture rtl of ff_sync is 

	type sig_b_array_t is array (sync_size-1 downto 0) of std_logic_vector(sig_b'range);
	signal sig_b_int : sig_b_array_t;
	signal sig_a_int : std_logic_vector(sig_a'range);

begin
	G1: if A1:  (pre_reg) generate 
	begin --use begin block like in verilog
		sync_a : process(clk_a) is
		begin
			if re_edge then
				if rising_edge(clk_a) then
					sig_a_int <= sig_a;
				end if;
			else
				if falling_edge(clk_a) then
					sig_a_int <= sig_a;
				end if;
			end if;
		end process;
	end A1;

	-- if you have problems with 2008 contruct remove alternative lables and
	-- begin/end delimiters and use the following.
	-- label : if not pre_reg generate
	else A2: generate
	begin

		sig_a_int <= sig_a;
	end A2;

	end generate G1;



	sync_b : process(clk_b)
	begin
		if re_edge then
			if rising_edge(clk_b) then
				sig_b_int <= sig_b_int(sync_size-2 downto 0) & sig_a_int;
			end if;
		else
			if falling_edge(clk_b) then
				sig_b_int <= sig_b_int(sync_size-2 downto 0) & sig_a_int;
			end if;
		end if;
	end process;

	sig_b <= sig_b_int(sync_size-1);

end architecture rtl;


--------------------------------------------------------------------------------
-- Testbench
--------------------------------------------------------------------------------
library ieee;
use	ieee.std_logic_1164.all;
library cdc_sync_lib;

entity ff_sync_tb is
end entity ff_sync_tb;

architecture tb of ff_sync_tb is

	constant vec_size : integer := 4;
	constant clk_a_period : time := 25 ns;
	constant clk_b_period : time := 15 ns;
	signal clk_a : std_logic;
	signal sig_a : std_logic_vector(vec_size-1 downto 0);
	signal clk_b : std_logic;
	signal sig_b : std_logic_vector(vec_size-1 downto 0);
	signal sig_a2 : std_logic;
	signal sig_b2 : std_logic;
begin

	uut1 : entity cdc_sync_lib.ff_sync 
	generic map(
			   pre_reg   => true,
			   --re_edge   : boolean := true,
			   sync_size => 2,
			   vec_size  => 4 --nibble
		   )
	port map (
			 clk_a => clk_a,
			 sig_a => sig_a,
			 clk_b => clk_b,
			 sig_b => sig_b
		 );

	uut2 : entity cdc_sync_lib.ff_sync 
	generic map(
			   pre_reg   => true,
			   --re_edge   : boolean := true,
			   sync_size => 2,
			   vec_size  => 1     --std_logic
		   )
	port map (
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

		for i in 1 to 100 loop
			wait until rising_edge(clk_a);
		end loop;

		sig_a <= x"6";
		sig_a2 <= '0';

		for i in 1 to 100 loop
			wait until rising_edge(clk_a);
		end loop;

		report "End of simulation" severity failure; -- force sim termination
		wait;
	end process;

end architecture tb;
