library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_keyboard IS
  GENERIC(
    clk_freq              : INTEGER;  --system clock frequency in Hz
    debounce_counter_size : INTEGER); --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
PORT(
  clk         : IN  STD_LOGIC;                     --system clock
  rst          : IN  STD_LOGIC;
  ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
  ps2_data     : IN  STD_LOGIC;                     --data signal from PS2 keyboard
  ps2_code_new : OUT STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
  ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --code received from PS/2
END entity;

architecture behavioral of ps2_keyboard is


  signal debounce_count : integer range 0 to debounce_counter_size;
signal count,previous_count : integer range 0 to 10;
signal valid: STD_LOGIC := '0';
begin

  -- we inferred latches multiple times, instead of using signals' logic (better approach)
    -- add debouncing logic to this process
      process(ps2_clk,rst)
        begin
          if(rst='1') then
            ps2_code_new<='0';
          ps2_code<=(others => '0');
          count<=0;
          elsif falling_edge(ps2_clk) then
          if(count = 0) then
          ps2_code_new<='0';
          if (ps2_data='0') then
            ps2_code<=(others => '0');
          count<=count+1;
          else
            count<=0;
        end if;
  elsif (count=10) then
    --output "ps2_code" stays the same
      if(ps2_data='1') then
        ps2_code_new<='1';
  else
    ps2_code_new<='0';
end if;
count<=0;
elsif (count=9) then
  --output "ps2_code" stays the same (inferred a latch, instead of adding a signal to store data in it)
    ps2_code_new<='0';
count<=count+1;        -- we dont need to check parity
  else           -- 1 until 8
    ps2_code(count-1)<=ps2_data;
count<=count+1;
end if;
end if;

end process;

-- am not sure how to check debouncing
  --   process(clk)
    --    begin
      --      if(rising_edge(clk)) then

        --        if (count /= 1) then
          --          debounce_count<=0;
      --      valid<='0';
      --        elsif (debounce_count /= debounce_counter_size) then
        --          debounce_count<=debounce_count+1;
      --          valid<='0';
      --        else
        --        debounce_count<=debounce_count;
      --         valid<='1';
      --      end if;

--end if;

--end process;



end behavioral;
