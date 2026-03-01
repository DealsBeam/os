## 2026-03-01 - [Optimizing Terminal Login Performance for Kali Extensions]
**Learning:** Using `apt list` to filter and display uninstalled packages is inefficient (~3.6s) as it performs extensive metadata processing. For simple list filtering of uninstalled packages, combining `apt-cache pkgnames` with `dpkg-query` and `comm` is significantly faster (~1.4s), reducing terminal login latency by ~60%.
**Action:** Always prefer `comm -23 <(apt-cache pkgnames | sort) <(dpkg-query -W -f='${Package}\n' | sort)` over `apt list` when only package names are needed for filtering.
