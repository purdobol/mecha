;;; omni-search-engines.el --- Consult Omni search engines -*- lexical-binding: t; -*-

;;; Commentary:
;; Search engine definitions for Consult Omni.
;;
;; Kept separate from source configuration.

;;; Code:


(setq consult-omni-search-engine-alist

'(

("[SEA] Brave"
 . "https://search.brave.com/search?q=%s")

("[SEA] DuckDuckGo"
 . "https://duckduckgo.com/?q=%s")

("[SEA] Google"
 . "https://www.google.com/search?q=%s")

("[SEA] Bing"
 . "https://www.bing.com/search?q=%s")

("[SEA] Startpage"
 . "https://www.startpage.com/do/search?q=%s")

("[SEA] SearXNG"
 . "https://searx.be/search?q=%s")

("[SEA] Kagi"
 . "https://kagi.com/search?q=%s")


("[AI] Perplexity"
 . "https://www.perplexity.ai/search?q=%s")

("[AI] You.com"
 . "https://you.com/search?q=%s")

("[AI] Andi"
 . "https://andisearch.com/?q=%s")

("[AI] Komo"
 . "https://komo.ai/search?q=%s")

("[AI] Exa"
 . "https://exa.ai/search?q=%s")


("[DEV] GitHub"
 . "https://github.com/search?q=%s")

("[DEV] GitLab"
 . "https://gitlab.com/search?search=%s")

("[DEV] CodeBerg"
 . "https://codeberg.org/explore/repos?q=%s")

("[DEV] StackOverflow"
 . "https://stackoverflow.com/search?q=%s")

("[DEV] StackExchange"
 . "https://stackexchange.com/search?q=%s")

("[DEV] Sourcegraph"
 . "https://sourcegraph.com/search?q=%s")


("[LIN] ArchWiki"
 . "https://wiki.archlinux.org/index.php?search=%s")

("[LIN] Arch Packages"
 . "https://archlinux.org/packages/?q=%s")

("[LIN] AUR"
 . "https://aur.archlinux.org/packages?K=%s")

("[LIN] Repology"
 . "https://repology.org/projects/?search=%s")

("[LIN] Linux Manuals"
 . "https://man7.org/linux/man-pages/search.html?q=%s")

("[LIN] Kernel.org"
 . "https://www.kernel.org/search/?q=%s")


("[EDU] Google Scholar"
 . "https://scholar.google.com/scholar?q=%s")

("[EDU] arXiv"
 . "https://arxiv.org/search/?query=%s&searchtype=all")

("[EDU] Semantic Scholar"
 . "https://www.semanticscholar.org/search?q=%s")

("[EDU] PubMed"
 . "https://pubmed.ncbi.nlm.nih.gov/?term=%s")


("[YOU] YouTube"
 . "https://www.youtube.com/results?search_query=%s")

("[YOU] PeerTube"
 . "https://search.joinpeertube.org/search?search=%s")

("[YOU] Odysee"
 . "https://odysee.com/$/search?q=%s")


("[SOC] Reddit"
 . "https://www.reddit.com/search/?q=%s")

("[SOC] Hacker News"
 . "https://hn.algolia.com/?q=%s")

("[SOC] Lobsters"
 . "https://lobste.rs/search?q=%s")


("[TOR] 1337x"
 . "https://1337x.to/search/%s/1/")

("[TOR] Nyaa"
 . "https://nyaa.si/?f=0&c=0_0&q=%s")

("[TOR] RuTracker"
 . "https://rutracker.org/forum/tracker.php?nm=%s")


("[MAP] OpenStreetMap"
 . "https://www.openstreetmap.org/search?query=%s")

("[MAP] Google Maps"
 . "https://www.google.com/maps/search/%s")

("[MAP] Apple Maps"
 . "https://maps.apple.com/?q=%s")


("[SHO] Amazon"
 . "https://www.amazon.com/s?k=%s")

("[SHO] Allegro"
 . "https://allegro.pl/listing?string=%s")

("[SHO] OLX"
 . "https://www.olx.pl/oferty/q-%s/")

("[SHO] Ceneo"
 . "https://www.ceneo.pl/;szukaj-%s")


("[EMA] MELPA"
 . "https://melpa.org/#/?q=%s")

("[EMA] GNU ELPA"
 . "https://elpa.gnu.org/packages/?q=%s")

("[EMA] Emacs Wiki"
 . "https://www.emacswiki.org/cgi-bin/wiki?search=%s")

("[EMA] Doom Emacs"
 . "https://github.com/search?q=%s+doom+emacs")


("[SEC] Exploit-DB"
 . "https://www.exploit-db.com/search?q=%s")

("[SEC] CVE"
 . "https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=%s")

("[SEC] Packet Storm"
 . "https://packetstormsecurity.com/search/?q=%s")


("[MOV] 1Shows"
 . "https://www.1shows.nl/search?query=%s")

("[MOV] BrocoFlix"
 . "https://brocoflix.xyz/pages/search?query=%s")

("[MOV] FlickyStream"
 . "https://flickystream.ru/search?q=%s")

("[MOV] HydraHD"
 . "https://hydrahd.ru/index.php?menu=search&query=g%s")

("[MOV] PopcornMovies"
 . "https://popcornmovies.org/search/%s")

("[MOV] SpenFlix"
 . "https://watch.spencerdevs.xyz/search?query=%s")


("[BOOK] Anna's Archive"
 . "https://annas-archive.li/search?q=%s")

("[BOOK] Liber3"
 . "https://liber3.eth.limo/#/search?q=%s")

("[BOOK] 1Shows"
 . "https://wvw.pdfdrive.to/top-%s-books")


))


(provide 'omni-search-engines)

;;; omni-search-engines.el ends here
