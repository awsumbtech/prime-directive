---
name: skillforge
description: Authors and validates new Prime Directive skills. Produces SKILL.md files with SSL-style three-layer manifests (scheduling, structural, logical) and validates them against retrieval, invocation, and audit requirements. Use when creating any new skill from scratch or restructuring an existing one.
metadata:
  manifest:
    scheduling:
      goal: author_validated_skill_artifact
      arguments:
        - skill_name
        - source_material
        - target_use_cases
      dependencies:
        - bash
        - view
        - str_replace
        - create_file
      triggers:
        - "/skillforge"
        - "create a new skill"
        - "draft a skill for"
        - "turn this SOP into a skill"
    structural:
      scenes:
        - id: gather
          type: read_only_discovery
        - id: draft_manifest
          type: structured_authoring
        - id: draft_body
          type: prose_authoring
        - id: validate
          type: self_check
        - id: dry_run
          type: simulation
        - id: present
          type: present_to_user
        - id: write
          type: write_with_approval
      entry: gather
      transitions:
        - gather -> draft_manifest
        - draft_manifest -> draft_body
        - draft_body -> validate
        - validate -> draft_manifest
        - validate -> dry_run
        - dry_run -> draft_body
        - dry_run -> present
        - present -> write
    logical:
      actions:
        - read
        - analyze
        - draft
        - write_with_approval
      resources:
        reads:
          - "skills/**/SKILL.md"
          - "CLAUDE.md"
          - "CLAUDE.local.md"
          - "agents/**"
          - source_material_path
        writes:
          - "skills/<new-skill-name>/SKILL.md"
          - "skills/<new-skill-name>/**"
        network: false
        credentials: false
      blast_radius: skill_library
      reversibility: backed_up_before_overwrite
---

# skillforge

Authors new skills that fit the Prime Directive framework. The output is a
SKILL.md file with a complete SSL-style manifest, a focused prose body, and
validation evidence that the skill will retrieve correctly, load only when
needed, and pass an invocation hygiene audit.

The manifest lives under the `metadata:` frontmatter key. Claude Code defines
`metadata` as the one free-form map it passes through without interpreting, so
that is where framework-specific structure belongs. Every other frontmatter key
must be one Claude Code recognizes.

This skill exists because skill authoring is the single highest-leverage
activity in the Prime Directive system. A bad skill pollutes retrieval, gets
invoked when it should not, and creates audit noise. A good skill compounds: it
gets loaded at the right time, does its job, and stays out of the way otherwise.

## When this skill applies

- Creating a new skill from scratch.
- Converting an existing SOP, runbook, or transcript into a skill.
- Restructuring a skill that audits flag as `phantom` or `relevance_drift`
  repeatedly.
- Splitting an over-broad skill into two narrower skills.
- Adding a manifest to a legacy skill that lacks one.

This skill does not apply to: editing skill prose for style, fixing typos, or
any change that does not touch the manifest or the skill's core procedure.

## Scene: gather (read-only)

Understand the source material and the existing library before drafting.

- Read the source (SOP, transcript, or topic description).
- Read the existing skills so the new one does not overlap or collide with an
  existing trigger surface.
- Identify the one job this skill does. If it has more than one job, it should
  be more than one skill.

## Scene: draft_manifest

Write the three-layer manifest:

- **Scheduling**: goal, arguments, dependencies, and triggers. Triggers must be
  specific enough that the skill loads for its job and not for adjacent tasks.
- **Structural**: the scenes (execution phases), the entry point, and the
  transitions between them including failure loops.
- **Logical**: actions, the resources it reads and writes, whether it touches
  network or credentials, its blast radius, and its reversibility.

## Scene: draft_body

Write the prose body: when it applies, when it does not, and each scene's
procedure. Keep it focused. Prose is Tier 3; do not pad it.

## Scene: validate (self-check)

Check five things before proceeding:

1. **Retrieval**: would this skill's description surface it for its intended
   tasks and not for others?
2. **Invocation discipline**: do the triggers pass a need check and a relevance
   check, or are they so broad the skill would phantom-load?
3. **Manifest-body consistency**: does the prose match what the manifest
   declares? No scene in one and missing in the other.
4. **Adjacent-skill discrimination**: is it clearly distinguishable from the
   nearest existing skill, or would they compete for the same triggers?
5. **Single responsibility**: one job. If validation reveals two, loop back and
   split.

If any check fails, return to draft_manifest or draft_body and fix it.

## Scene: dry_run

Simulate two or three realistic invocations. Walk the scenes as if executing.
If the dry run reveals a gap (a scene that cannot actually be carried out, a
missing argument), loop back to draft_body.

## Scene: present

Show the user the complete skill, the validation evidence, and any design
decisions that need their specific input before it is written.

## Scene: write (with approval)

On approval, write the skill. If overwriting an existing skill, back it up
first. If replacing an over-broad skill with two narrower ones, archive the
original with a deprecation note pointing to the replacements rather than
deleting it.

## Notes

This skill borrows its structural approach from arXiv 2604.24026
(Scheduling-Structural-Logical representation) and its retrieval and invocation
discipline from arXiv 2604.24594 (Skill Retrieval Augmentation). Neither paper
is required reading to use skillforge, but both are worth knowing if you want to
extend the framework.
