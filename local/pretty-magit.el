;;; ~/.doom.d/local/pretty-magit.el -*- lexical-binding: t; -*-

;; All credit goes to Eric Kaschalk @ www.modernemacs.com
;; For this code: http://www.modernemacs.com/post/pretty-magit/
(require 'dash)
(require 'all-the-icons)
(require 'helm)
(require 'evil)
(require 'magit)

(provide 'pretty-magit)

(defmacro pretty-magit (WORD ICON PROPS &optional NO-PROMPT?)
  "Replace sanitized WORD with ICON, PROPS and by default add to prompts."
  `(prog1
       (add-to-list `pretty-magit-alist
                    (list (rx bow (group ,WORD (eval (if ,NO-PROMPT? "" ":"))))
                          ,ICON ',PROPS))
     (unless ,NO-PROMPT?
       (add-to-list `pretty-magit-prompt (concat ,WORD ":")))))

(setq pretty-magit-alist nil)
(setq pretty-magit-prompt nil)
(pretty-magit "Add" (all-the-icons-octicon "git-commit") (:foreground "#3dce00" :height 1.2))
(pretty-magit "Fix" (all-the-icons-octicon "bug") (:foreground "#ff6c4f" :height 1.2))
(pretty-magit "Clean" (all-the-icons-faicon "cut") (:foreground "#ffca4f" :height 1.2))
(pretty-magit "Docs" (all-the-icons-octicon "info") (:foreground "#bfbfbf" :height 1.2))
(pretty-magit "Feature" (all-the-icons-octicon "checklist") (:foreground "#bfbfbf" :height 1.2))
(pretty-magit "Merge" (all-the-icons-octicon "merge") (:foreground "#a100c1" :height 1.2))

(defun add-magit-faces ()
  "Add face properties and compose symbols for buffer from pretty-magit"
  (interactive)
  (with-silent-modifications
    (--each pretty-magit-alist
      (-let (((rgx icon props) it))
        (save-excursion
          (goto-char (char-min))
          (while (search-forward-regexp rgx nil t)
            (compose-region
             (match-beginning 1) (match-end 1) icon)
            (when props
              (add-face-text-property
               (match-beginning 1) (match-end 1) props))))))))

(advice-add 'magit-status :after  'add-magit-faces)
(advice-add 'magit-refresh-buffer  :after 'add-magit-faces)

(setq use-magit-commit-prompt-p nil)
(defun use-magit-commit-prompt (&rest args)
  (setq  use-magit-commit-prompt-p t))

(defun magit-commit-prompt ()
  "Magit prompt and insert commit header with faces."
  (interactive)
  (when use-magit-commit-prompt-p
    (setq use-magit-commit-prompt-p nil)
    (insert (helm :sources (helm-build-sync-source "Commit Type "
                             :candidates pretty-magit-prompt)
                  :buffer "*magit cmt prompt*"))
    (add-magit-faces)
    (evil-insert 1)))

(remove-hook 'git-commit-setup-hook 'with-editor-usage-message)
(add-hook 'git-commit-setup-hook 'magit-commit-prompt)
(advice-add 'magit-commit :after 'use-magit-commit-prompt)
