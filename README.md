![elogo](https://raw.githubusercontent.com/Rexamm1t/NextRAM/refs/heads/main/github/IMG_20250907_140904.jpg)

<div id="badges">
  <a 
href="https://t.me/rexamm1t_channel"
><img src="https://img.shields.io/badge/Telegram-blue?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Badge" /></a>
  <a href="https://github.com/Rexamm1t/NextRAM/releases/latest"><img src="https://img.shields.io/github/v/release/Rexamm1t/NextRAM" alt="Latest Release" /></a>
</div>



NextRam  - is a powerful Magisk module that enhances Android performance through intelligent management of ZRAM and swap file. It automatically adjusts optimal swap settings, improving multitasking and reducing lags on devices with low RAM.  



Main functions:

Automatic zRam configuration

- Dynamically selects the best compression algorithm (zstd → lz4 → lzo → lz4hc → deflate).  
- The optimal size of ZRAM (by default, 65% of the RAM, can be changed).  
- Full support for old and new cores (if ZRAM is unavailable, the module will continue to work with the swap file).


Smart swap file

- Creates a swap file in the module folder
- Free space monitoring – will not be activated if there is insufficient memory.  
- Automatic mounting after reboot (added to fstab).  
- Does not activate when the battery is low (<15%).  

Compatibility

- Supports different file systems (ext4, F2FS, etc.).
- Takes into account SELinux (tries to set the correct context).
