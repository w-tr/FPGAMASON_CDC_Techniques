library ieee;
use ieee.std_logic_1164.all;

entity hdshk_pulse_sync is
    port
    (
	clka : in  std_logic;
	siga : in  std_logic;
	clkb : in  std_logic;
	sigb : out std_logic;
	busy : out std_logic
    );
end entity hdshk_pulse_sync;

architecture rtl of hdshk_pulse_sync is

    b1   : std_logic;
    b2   : std_logic;
    b3   : std_logic;
    a1   : std_logic;
    a2   : std_logic;
    a3   : std_logic;
    mux1 : std_logic;
    mux2 : std_logic;

begin

    -- non clk'd
    busy <= sig_a(2) AND sig_a(0);
    sigb <= b2 and not b3;

    mux1 <= a1 when a3='0' else '1';
    mux2 <= mux1 when siga='0' else '1';

    process(clkb) is
    begin
	if rising_edge(clkb) then
	    b1 <= a1;
	    b2 <= b1;
	    b3 <= b2;
	end if;
    end process;

    process(clka) is
    begin
	if rising_edge(clka) then
	    a1 <= mux2;
	    a2 <= b2;
	    a3 <= a1;
	end if;
    end process;

end architecture rtl;
