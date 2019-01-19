;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; bindings

(map!
 (:map evilem-map
   :after evil-easymotion
   "<down>" #'evilem-motion-next-line
   "<up>"   #'evilem-motion-previousline)
 (:leader
   (:prefix "f"
     :desc "Toggle Treemacs" "t" #'+treemacs/toggle))

 (:map evil-window-map
   "<left>"  #'evil-window-left
   "<right>" #'evil-window-right
   "<up>"    #'evil-window-up
   "<down>"  #'evil-window-down)

 "<home>" #'back-to-indentation-or-begginning
 "<end>"  #'end-to-line)

(setq ON-LAPTOP (string= (system-name) "TaigaTop"))

(if ON-LAPTOP
    (progn)
  (progn
    (def-package! discord-emacs)
    (setq org-ditaa-jar-path "/usr/share/java/ditaa/ditaa-0.11.jar")
    (setq org-plantuml-jar-path "/opt/plantuml/plantuml.jar")
    (run-at-time "1 min" nil #'discord-emacs-run "384815451978334208")))

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (dot . t)
     (ditaa . t)
     (haskell . t)
     (sql . t)))
  (setq org-tags-column 100))

(set-irc-server! "chat.freenode.net"
                 `(:tls t
                        :nick "YuiYukihira"
                        :sasl-username ,(+pass-get-user "irc/freenode.net")
                        :sasl-password (lambda (&rest _) (+pass-get-secret "irc/freenode.net"))
                        :channels (:after-auth "#emacs" "##linux" "#reddit-dailyprogrammer" "#redditanime" "#reddit-uk" "#archlinux")
                        :port 6697))

;; Because shit be fucking borked with ssl and irc
(setq tls-end-of-info
      (concat
       "\\("
       ;; `openssl s_client' regexp.  See ssl/ssl_txt.c lines 219-220.
       ;; According to apps/s_client.c line 1515 `---' is always the last
       ;; line that is printed by s_client before the real data.
       "^    Verify return code: .+\n\\(\\|^    Extended master secret: .+\n\\)---\n\\|"
       ;; `gnutls' regexp. See src/cli.c lines 721-.
       "^- Simple Client Mode:\n"
       "\\(\n\\|"                           ; ignore blank lines
       ;; According to GnuTLS v2.1.5 src/cli.c lines 640-650 and 705-715
       ;; in `main' the handshake will start after this message.  If the
       ;; handshake fails, the programs will abort.
       "^\\*\\*\\* Starting TLS handshake\n\\)*"
       "\\)"))
