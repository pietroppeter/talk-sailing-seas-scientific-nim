# Spec Delta

## ADDED Requirements

### Requirement: Audience segments by background
The talk SHALL keep in mind that, beside the Python/Jupyter majority, the room may include R users, C++ and HPC people, and people from other corners of scientific computing, and SHALL avoid examples that only make sense to Python users.

#### Scenario: Non-Python attendee
- **WHEN** an R or C++ user watches an island
- **THEN** the example still makes sense to them, and where it helps, a comparison to their language is given

### Requirement: Audience segments by role
The talk SHALL keep in mind both library authors and maintainers, who judge Nim as a language to build tools in, and library users and practitioners, who judge it as a tool for their daily work.

#### Scenario: Checking the outline by role
- **WHEN** the outline is reviewed
- **THEN** each island is marked as speaking mainly to authors, to users, or to both
