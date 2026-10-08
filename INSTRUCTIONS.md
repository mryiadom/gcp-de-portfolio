# Standing instructions

Running log of instructions given to the assistant for this repo, so they carry forward
instead of getting lost mid-conversation.

- **2026-09-02** — Don't give answers to exercises unless the user is really stuck and
  asks for help. Explain what a task is asking for, point at the relevant concept, but
  let the user write and debug the code themselves. This includes naming the specific
  missing clause/fix (e.g. "add an ORDER BY on X") — that's still the answer, just
  phrased as an instruction. When something's wrong or incomplete, say what requirement
  isn't met yet, not what to add to fix it.
- **2026-09-02** — Once a full week is completed (all 5 days), tick that week's checkbox
  in `README.md` — not per-day, whole-week only. Note: the checkboxes in
  `docs/gcp-de-tracker.html` live in the browser's `localStorage`, not in the file —
  those have to be ticked by the user in-browser, they can't be updated from the repo.
- **2026-10-05** — When presenting a day's exercises, recommend a **learning order**: say
  what to read or watch *before* each exercise, with links to the resources, rather than
  just listing the exercises. Use the roadmap's own resources for that week where they fit
  (the tracker has videos with chapter timestamps), plus official docs. Only link pages
  that have been checked to load.
- **2026-10-05** — If an exercise has no resource to point at (no video, doc or tutorial
  that covers it), explain the concept directly instead, with worked examples where they
  help. Don't just say there's nothing to link. Still don't write the exercise's answer
  for them: explain the idea with a different example from the one they're asked about.
- **2026-10-06** — Keep the "Currently on: Week N" line in `README.md` (just above the
  Progress checklist) up to date: when a week is ticked complete, move the line to the
  next week and update the "N of 33 weeks complete" count.
- **2026-10-08** — The Professional Data Engineer certification track runs alongside the
  roadmap (exam bridges on Weeks 5, 12–22 and 27–33, plus a *Ready to book* checklist in the
  tracker's Certification track panel). The user decides when to book the exam: don't
  schedule the booking for them. Instead, say when they look ready, measured against the
  *Ready to book* checklist.
