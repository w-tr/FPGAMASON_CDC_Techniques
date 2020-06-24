--   ____ ___   __    _               
--  / __// o |,'_/  .' \              
-- / _/ / _,'/ /_n / o /   _   __  _    ___  _   _  __
--/_/  /_/   |__,'/_n_/   / \,' /.' \ ,' _/,' \ / |/ /
--                       / \,' // o /_\ `./ o // || / 
--                      /_/ /_//_n_//___,'|_,'/_/|_/ 
-- 
-- For when clocks are asynchronous to each other but events last multiple clocks
-- in the clock domain being synched to.
-- Often used to combat metastability.
-- If you can't verify on a vhdl-2008 platform then use alternative for generate statement
-- 

library ieee;
use ieee.std_logic_1164.all;

entity ff_sync is 
    generic
    (
        pre_reg   : boolean := false;
        re_edge   : boolean := true;
        sync_size : integer := 2
    );
    port 
    (
        clk_a : in  std_logic;
        sig_a : in  std_logic;
        clk_b : in  std_logic;
        sig_b : out std_logic
    );
end entity ff_sync;

architecture rtl of ff_sync is 

    signal sig_a_int : std_logic;
    signal sig_b_int : std_logic_vector(sync_size-1 downto 0);

begin

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Allow a pre registration stage for signal A.
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    end A1; else A2: generate
    begin
        sig_a_int <= sig_a;
    end A2; end generate G1;

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- 2 stage FF to shift clock domains.
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
