-- =====================================================
-- Migration Script: ERD Update
-- Generated: 2025-11-17
-- Purpose: Create new tables from ERD_update.md while preserving existing Candidate-related tables
-- Database: PostgreSQL
-- =====================================================

BEGIN;

-- =====================================================
-- SECTION 1: CREATE CORE TABLES (no dependencies)
-- =====================================================

-- Table: COMPANY
-- Description: Stores company information
CREATE TABLE IF NOT EXISTS "Company" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: INTERVIEW_FLOW
-- Description: Defines interview process flows
CREATE TABLE IF NOT EXISTS "InterviewFlow" (
    id SERIAL PRIMARY KEY,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: INTERVIEW_TYPE
-- Description: Catalog of interview types (technical, HR, etc.)
CREATE TABLE IF NOT EXISTS "InterviewType" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SECTION 2: CREATE DEPENDENT TABLES (Level 1)
-- =====================================================

-- Table: EMPLOYEE
-- Description: Company employees who conduct interviews
CREATE TABLE IF NOT EXISTS "Employee" (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_company FOREIGN KEY (company_id) 
        REFERENCES "Company"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_employee_email UNIQUE (email)
);

-- Table: POSITION
-- Description: Job positions offered by companies
CREATE TABLE IF NOT EXISTS "Position" (
    id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL,
    interview_flow_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    is_visible BOOLEAN DEFAULT false,
    location VARCHAR(255),
    job_description TEXT,
    requirements TEXT,
    responsibilities TEXT,
    salary_min NUMERIC(10, 2),
    salary_max NUMERIC(10, 2),
    employment_type VARCHAR(50),
    benefits TEXT,
    company_description TEXT,
    application_deadline DATE,
    contact_info VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_position_company FOREIGN KEY (company_id) 
        REFERENCES "Company"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_position_interview_flow FOREIGN KEY (interview_flow_id) 
        REFERENCES "InterviewFlow"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_position_status CHECK (status IN ('draft', 'open', 'closed', 'on_hold')),
    CONSTRAINT chk_position_employment_type CHECK (employment_type IN ('full_time', 'part_time', 'contract', 'temporary', 'internship')),
    CONSTRAINT chk_salary_range CHECK (salary_max IS NULL OR salary_min IS NULL OR salary_max >= salary_min)
);

-- Table: INTERVIEW_STEP
-- Description: Steps within an interview flow
CREATE TABLE IF NOT EXISTS "InterviewStep" (
    id SERIAL PRIMARY KEY,
    interview_flow_id INTEGER NOT NULL,
    interview_type_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_interview_step_flow FOREIGN KEY (interview_flow_id) 
        REFERENCES "InterviewFlow"(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_interview_step_type FOREIGN KEY (interview_type_id) 
        REFERENCES "InterviewType"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_order_index CHECK (order_index >= 0)
);

-- =====================================================
-- SECTION 3: CREATE DEPENDENT TABLES (Level 2)
-- =====================================================

-- Table: APPLICATION
-- Description: Candidate applications to positions
CREATE TABLE IF NOT EXISTS "Application" (
    id SERIAL PRIMARY KEY,
    position_id INTEGER NOT NULL,
    candidate_id INTEGER NOT NULL,
    application_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'submitted',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_application_position FOREIGN KEY (position_id) 
        REFERENCES "Position"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_application_candidate FOREIGN KEY (candidate_id) 
        REFERENCES "Candidate"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_application_status CHECK (status IN ('submitted', 'under_review', 'interview', 'rejected', 'accepted', 'withdrawn'))
);

-- =====================================================
-- SECTION 4: CREATE DEPENDENT TABLES (Level 3)
-- =====================================================

-- Table: INTERVIEW
-- Description: Individual interview sessions
CREATE TABLE IF NOT EXISTS "Interview" (
    id SERIAL PRIMARY KEY,
    application_id INTEGER NOT NULL,
    interview_step_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    interview_date DATE NOT NULL,
    result VARCHAR(50),
    score INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_interview_application FOREIGN KEY (application_id) 
        REFERENCES "Application"(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_interview_step FOREIGN KEY (interview_step_id) 
        REFERENCES "InterviewStep"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_interview_employee FOREIGN KEY (employee_id) 
        REFERENCES "Employee"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_interview_result CHECK (result IN ('passed', 'failed', 'pending', 'no_show')),
    CONSTRAINT chk_interview_score CHECK (score IS NULL OR (score >= 0 AND score <= 100))
);

-- =====================================================
-- SECTION 5: CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Indexes for EMPLOYEE
CREATE INDEX IF NOT EXISTS idx_employee_company_id ON "Employee"(company_id);
CREATE INDEX IF NOT EXISTS idx_employee_email ON "Employee"(email);
CREATE INDEX IF NOT EXISTS idx_employee_is_active ON "Employee"(is_active);

-- Indexes for POSITION
CREATE INDEX IF NOT EXISTS idx_position_company_id ON "Position"(company_id);
CREATE INDEX IF NOT EXISTS idx_position_interview_flow_id ON "Position"(interview_flow_id);
CREATE INDEX IF NOT EXISTS idx_position_status ON "Position"(status);
CREATE INDEX IF NOT EXISTS idx_position_is_visible ON "Position"(is_visible);
CREATE INDEX IF NOT EXISTS idx_position_application_deadline ON "Position"(application_deadline);

-- Indexes for INTERVIEW_STEP
CREATE INDEX IF NOT EXISTS idx_interview_step_flow_id ON "InterviewStep"(interview_flow_id);
CREATE INDEX IF NOT EXISTS idx_interview_step_type_id ON "InterviewStep"(interview_type_id);
CREATE INDEX IF NOT EXISTS idx_interview_step_order ON "InterviewStep"(order_index);

-- Indexes for APPLICATION
CREATE INDEX IF NOT EXISTS idx_application_position_id ON "Application"(position_id);
CREATE INDEX IF NOT EXISTS idx_application_candidate_id ON "Application"(candidate_id);
CREATE INDEX IF NOT EXISTS idx_application_status ON "Application"(status);
CREATE INDEX IF NOT EXISTS idx_application_date ON "Application"(application_date);

-- Indexes for INTERVIEW
CREATE INDEX IF NOT EXISTS idx_interview_application_id ON "Interview"(application_id);
CREATE INDEX IF NOT EXISTS idx_interview_step_id ON "Interview"(interview_step_id);
CREATE INDEX IF NOT EXISTS idx_interview_employee_id ON "Interview"(employee_id);
CREATE INDEX IF NOT EXISTS idx_interview_date ON "Interview"(interview_date);
CREATE INDEX IF NOT EXISTS idx_interview_result ON "Interview"(result);

-- =====================================================
-- SECTION 6: COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE "Company" IS 'Stores information about companies using the ATS';
COMMENT ON TABLE "Employee" IS 'Company employees who participate in the hiring process';
COMMENT ON TABLE "Position" IS 'Job positions posted by companies';
COMMENT ON TABLE "InterviewFlow" IS 'Defines the interview process workflow';
COMMENT ON TABLE "InterviewStep" IS 'Individual steps within an interview flow';
COMMENT ON TABLE "InterviewType" IS 'Types of interviews (technical, HR, cultural fit, etc.)';
COMMENT ON TABLE "Application" IS 'Candidate applications to job positions';
COMMENT ON TABLE "Interview" IS 'Individual interview sessions between candidates and employees';

COMMIT;

-- =====================================================
-- ROLLBACK SCRIPT (COMMENTED OUT FOR SAFETY)
-- =====================================================
-- To rollback this migration, execute the following in order:
--
-- BEGIN;
-- DROP TABLE IF EXISTS "Interview" CASCADE;
-- DROP TABLE IF EXISTS "Application" CASCADE;
-- DROP TABLE IF EXISTS "InterviewStep" CASCADE;
-- DROP TABLE IF EXISTS "Position" CASCADE;
-- DROP TABLE IF EXISTS "Employee" CASCADE;
-- DROP TABLE IF EXISTS "InterviewType" CASCADE;
-- DROP TABLE IF EXISTS "InterviewFlow" CASCADE;
-- DROP TABLE IF EXISTS "Company" CASCADE;
-- COMMIT;
--
-- NOTE: This will permanently delete all data in these tables!
-- Existing tables (Candidate, Education, WorkExperience, Resume) will remain intact.

-- =====================================================
-- VERIFICATION QUERIES (OPTIONAL)
-- =====================================================
-- After running the migration, verify with:
--
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
-- ORDER BY table_name;
--
-- SELECT constraint_name, table_name, constraint_type 
-- FROM information_schema.table_constraints
-- WHERE table_schema = 'public' AND constraint_type IN ('FOREIGN KEY', 'PRIMARY KEY')
-- ORDER BY table_name, constraint_type;

