library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
 
    
entity Clocks is
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        v_count : in integer range 0 to V_RES + V_SYNC_PULSE + V_FRONT_PORCH + V_BACK_PORCH;
        vga_clk : out STD_LOGIC;
        frame_clk : out STD_LOGIC;
        game_clk : out STD_LOGIC
    );
end Clocks;

   
architecture Behavioral of Clocks is

    signal cnt_vga : STD_LOGIC := '0'; -- auxillary bit to divide 100 MHz clock by 4
    signal cnt_frame : integer range 0 to 15 := 0; -- auxillary bit to divide 100 MHz clock by 4
    signal my_vga_clk,my_frame_clk,my_game_clk : STD_LOGIC := '0';

begin 
    
    vga_clk <= my_vga_clk;
    frame_clk <= my_frame_clk;
    game_clk <= my_game_clk;
    process(clk) --clock division from 100 MHz to 25 MHz
    begin
        if reset = '1' then
            cnt_vga <= '0';
            my_vga_clk <= '0';
        elsif rising_edge(clk) then
            if cnt_vga = '1' then
                my_vga_clk <= not my_vga_clk;
            end if;
            cnt_vga <=  not cnt_vga;
        end if;
    end process;

    process(my_vga_clk) -- generate input sampling clock (25 MHz to input_sampling_rate)
    begin
        if (reset = '1') then
            my_frame_clk <= '0';
        elsif rising_edge(my_vga_clk) then
            if v_count >= V_SYNC_PULSE + V_BACK_PORCH + V_RES + V_FRONT_PORCH  - 1 then
                my_frame_clk <= '1';  
            elsif v_count >= V_SYNC_PULSE then
                my_frame_clk <= '0';
            else
                my_frame_clk <= '1';
            end if;
        end if;
    end process;

    process(my_frame_clk) --slow clock for snake movement
    begin
        if reset = '1' then
            cnt_frame <= 0;
            my_game_clk <= '0';
        elsif rising_edge(my_frame_clk) then
            if cnt_frame >= 15 then
                cnt_frame <= 0;
                my_game_clk <= not my_game_clk;
            else
                cnt_frame <=  cnt_frame +1;
            end if;
        end if;
    end process;
    

end Behavioral;