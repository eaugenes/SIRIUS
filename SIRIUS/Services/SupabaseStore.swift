//
//  SupabaseStore.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// All database reads / writes for accounts, jobs and applications.
// Table and column names match supabase_schema.sql + supabase_migration_2.sql.

import Foundation
import Supabase

// MARK: - Rows

struct ApplicantRow: Codable, Sendable {
    var id: UUID
    var firstName: String
    var middleName: String
    var lastName: String
    var contactNumber: String
    var location: String
    var program: String
    var yrsExp: Double
    var coreLang: [String]
    var workSetup: String
    var resumePath: String
    var birthDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case middleName = "middle_name"
        case lastName = "last_name"
        case contactNumber = "contact_number"
        case location, program
        case yrsExp = "yrs_exp"
        case coreLang = "core_lang"
        case workSetup = "work_setup"
        case resumePath = "resume_path"
        case birthDate = "birth_date"
    }
    
    init(_ a: Applicant) {
        id = a.id
        firstName = a.firstName
        middleName = a.middleName
        lastName = a.lastName
        contactNumber = a.contactNumber
        location = a.location
        program = a.program
        yrsExp = a.yrExp
        coreLang = a.coreLang
        workSetup = a.workSetUp
        resumePath = a.resumeFileName
        birthDate = a.birthDate
    }
    
    func applicant(email: String) -> Applicant {
        var a = Applicant(
            id: id, firstName: firstName, middleName: middleName, lastName: lastName,
            contactNumber: contactNumber, location: location, program: program,
            yrExp: yrsExp, coreLang: coreLang, workSetUp: workSetup, email: email, password: ""
        )
        a.birthDate = birthDate
        a.resumeFileName = resumePath
        a.username = email.split(separator: "@").first.map(String.init) ?? ""
        return a
    }
}

struct EmployerRow: Codable, Sendable {
    var id: UUID
    var firstName: String
    var middleName: String
    var lastName: String
    var birthDate: String
    var contactNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case middleName = "middle_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case contactNumber = "contact_number"
    }
    
    init(_ e: Employer) {
        id = e.id
        firstName = e.firstName
        middleName = e.middleName
        lastName = e.lastName
        birthDate = e.birthDate
        contactNumber = e.contactNumber
    }
    
    func employer(email: String) -> Employer {
        var e = Employer()
        e.id = id
        e.firstName = firstName
        e.middleName = middleName
        e.lastName = lastName
        e.birthDate = birthDate
        e.contactNumber = contactNumber
        e.email = email
        e.username = email.split(separator: "@").first.map(String.init) ?? ""
        return e
    }
}

struct CompanyRow: Codable, Sendable {
    var id: UUID
    var name: String
    var about: String
    var founded: String
    var location: String
    var website: String
    var email: String
    
    init(_ c: Company, ownerID: UUID) {
        id = ownerID
        name = c.cmpName
        about = c.cmpDesc
        founded = c.founded
        location = c.loc
        website = c.website
        email = c.email
    }
    
    func company() -> Company {
        var c = Company()
        c.id = id.uuidString.lowercased()
        c.cmpName = name
        c.cmpDesc = about
        c.founded = founded
        c.loc = location
        c.website = website
        c.email = email
        return c
    }
}

private struct CompanyNameRow: Codable, Sendable {
    var name: String
}

struct JobRow: Codable, Sendable {
    var id: UUID
    var companyID: UUID
    var jobPos: String
    var jobDesc: String
    var requiredLoc: String
    var requiredProgram: String
    var requiredYrExp: Double
    var requiredLang: [String]
    var workSetup: String
    var maxHire: Int
    var salary: Int
    var isActive: Bool
    var isFilled: Bool
    var datePosted: Date
    fileprivate var companies: CompanyNameRow?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyID = "company_id"
        case jobPos = "job_pos"
        case jobDesc = "job_desc"
        case requiredLoc = "required_loc"
        case requiredProgram = "required_program"
        case requiredYrExp = "required_yr_exp"
        case requiredLang = "required_lang"
        case workSetup = "work_setup"
        case maxHire = "max_hire"
        case salary
        case isActive = "is_active"
        case isFilled = "is_filled"
        case datePosted = "date_posted"
        case companies
    }
    
    func job() -> Job {
        Job(
            jobID: id.uuidString.lowercased(),
            companyID: companyID.uuidString.lowercased(),
            jobPos: jobPos,
            jobDesc: jobDesc,
            requiredLoc: requiredLoc,
            requiredProgram: requiredProgram,
            requiredYrExp: requiredYrExp,
            requiredLang: requiredLang,
            workSetup: WorkSetup(rawValue: workSetup) ?? .onSite,
            maxHire: maxHire,
            applicantCount: 0,
            datePosted: datePosted,
            isActive: isActive,
            companyName: companies?.name ?? "",
            isFilled: isFilled,
            salary: salary
        )
    }
}

// What the app sends when it creates or edits a job
private struct JobWrite: Encodable, Sendable {
    var id: UUID
    var company_id: UUID
    var job_pos: String
    var job_desc: String
    var required_loc: String
    var required_program: String
    var required_yr_exp: Double
    var required_lang: [String]
    var work_setup: String
    var max_hire: Int
    var salary: Int
    var is_active: Bool
    var is_filled: Bool
    var date_posted: Date
    
    init?(_ job: Job) {
        guard let id = UUID(uuidString: job.jobID), let company = UUID(uuidString: job.companyID) else { return nil }
        self.id = id
        company_id = company
        job_pos = job.jobPos
        job_desc = job.jobDesc
        required_loc = job.requiredLoc
        required_program = job.requiredProgram
        required_yr_exp = job.requiredYrExp
        required_lang = job.requiredLang
        work_setup = job.workSetup.rawValue
        max_hire = job.maxHire
        salary = job.salary
        is_active = job.isActive
        is_filled = job.isFilled
        date_posted = job.datePosted
    }
}

private struct JobStatusUpdate: Encodable, Sendable {
    var is_active: Bool
    var is_filled: Bool
}

struct ApplicationRow: Codable, Sendable {
    var id: UUID
    var jobID: UUID
    var applicantID: UUID
    var status: String
    var score: Int
    var rejectionReason: String
    var isRemoved: Bool
    var isWithdrawn: Bool
    var interviewAt: Date?
    var interviewLocation: String
    var interviewMessage: String
    var createdAt: Date
    var applicants: ApplicantRow?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobID = "job_id"
        case applicantID = "applicant_id"
        case status, score
        case rejectionReason = "rejection_reason"
        case isRemoved = "is_removed"
        case isWithdrawn = "is_withdrawn"
        case interviewAt = "interview_at"
        case interviewLocation = "interview_location"
        case interviewMessage = "interview_message"
        case createdAt = "created_at"
        case applicants
    }
}

private struct InterviewUpdate: Encodable, Sendable {
    var status: String
    var interview_at: Date
    var interview_location: String
    var interview_message: String
}

private struct StatusUpdate: Encodable, Sendable {
    var status: String
}

private struct RemoveUpdate: Encodable, Sendable {
    var is_removed: Bool = true
    var rejection_reason: String
}

private struct JobParam: Encodable, Sendable {
    var p_job: UUID
}

private struct WithdrawParam: Encodable, Sendable {
    var p_id: UUID
}

// MARK: - Store

enum SupabaseStore {
    
    private static var db: SupabaseClient { SupabaseService.client }
    
    static func statusText(_ status: EmpAplStatus) -> String {
        switch status {
        case .toReview: return "review"
        case .interview: return "interview"
        case .hired: return "hired"
        }
    }
    
    private static func status(from text: String) -> EmpAplStatus {
        switch text {
        case "interview": return .interview
        case "hired": return .hired
        default: return .toReview
        }
    }
    
    // MARK: Accounts
    
    static func saveApplicant(_ applicant: Applicant) async throws {
        try await db.from("applicants").upsert(ApplicantRow(applicant)).execute()
    }
    
    static func fetchApplicant(id: UUID, email: String) async throws -> Applicant? {
        let rows: [ApplicantRow] = try await db.from("applicants")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows.first?.applicant(email: email)
    }
    
    static func saveEmployer(_ employer: Employer, company: Company, userID: UUID) async throws {
        var owner = employer
        owner.id = userID
        try await db.from("companies").upsert(CompanyRow(company, ownerID: userID)).execute()
        try await db.from("employers").upsert(EmployerRow(owner)).execute()
    }
    
    static func fetchEmployer(id: UUID, email: String) async throws -> (Employer, Company)? {
        let employers: [EmployerRow] = try await db.from("employers")
            .select().eq("id", value: id).limit(1).execute().value
        let companies: [CompanyRow] = try await db.from("companies")
            .select().eq("id", value: id).limit(1).execute().value
        guard let employerRow = employers.first, let companyRow = companies.first else { return nil }
        return (employerRow.employer(email: email), companyRow.company())
    }
    
    // MARK: Board (jobs, applications, interviews)
    
    // Row Level Security decides what each user gets: an applicant sees active jobs and their own
    // applications; an employer sees their own jobs and the applications on them.
    static func fetchBoard() async throws -> (jobs: [Job], applications: [ApplicationRecord], interviews: [Interview]) {
        let jobRows: [JobRow] = try await db.from("jobs")
            .select("*, companies(name)")
            .order("date_posted", ascending: false)
            .execute()
            .value
        let jobs = jobRows.map { $0.job() }
        
        let applicationRows: [ApplicationRow] = try await db.from("applications")
            .select("*, applicants(*)")
            .order("created_at", ascending: true)
            .execute()
            .value
        
        var records: [ApplicationRecord] = []
        var interviews: [Interview] = []
        
        for row in applicationRows {
            let jobID = row.jobID.uuidString.lowercased()
            guard let job = jobs.first(where: { $0.jobID == jobID }),
                  let applicantRow = row.applicants else { continue }
            let applicant = applicantRow.applicant(email: "")
            let breakdown = Matching.evaluate(applicant.matchProfile, against: job.matchRequirements)
            
            let record = ApplicationRecord(
                id: row.id,
                jobID: jobID,
                applicantID: row.applicantID,
                applicantName: applicant.fullName,
                degree: applicant.program,
                yearsExperience: applicant.yrExp,
                languages: applicant.coreLang,
                breakdown: breakdown,
                status: status(from: row.status),
                location: applicant.location,
                resumeFileName: applicant.resumeFileName,
                rejectionReason: row.rejectionReason,
                isWithdrawn: row.isWithdrawn,
                isRemoved: row.isRemoved,
                dateApplied: row.createdAt
            )
            records.append(record)
            
            if let date = row.interviewAt, !row.isRemoved, !row.isWithdrawn {
                interviews.append(Interview(
                    applicantID: row.id,
                    date: date,
                    location: row.interviewLocation,
                    message: row.interviewMessage
                ))
            }
        }
        return (jobs, records, interviews)
    }
    
    // MARK: Jobs
    
    static func insertJob(_ job: Job) async throws {
        guard let row = JobWrite(job) else { return }
        try await db.from("jobs").insert(row).execute()
    }
    
    static func updateJob(_ job: Job) async throws {
        guard let row = JobWrite(job) else { return }
        try await db.from("jobs").update(row).eq("id", value: row.id).execute()
    }
    
    static func setJobStatus(jobID: String, isActive: Bool, isFilled: Bool) async throws {
        guard let id = UUID(uuidString: jobID) else { return }
        try await db.from("jobs")
            .update(JobStatusUpdate(is_active: isActive, is_filled: isFilled))
            .eq("id", value: id)
            .execute()
    }
    
    static func deleteJob(jobID: String) async throws {
        guard let id = UUID(uuidString: jobID) else { return }
        try await db.from("jobs").delete().eq("id", value: id).execute()
    }
    
    // Server-side matching: applies every matching applicant (and refreshes scores) for one job
    static func autoApply(jobID: String) async throws {
        guard let id = UUID(uuidString: jobID) else { return }
        try await db.rpc("auto_apply_for_job", params: JobParam(p_job: id)).execute()
    }
    
    // Server-side matching for the signed-in applicant against every active job
    static func autoApplyCurrentApplicant() async throws {
        try await db.rpc("auto_apply_for_applicant").execute()
    }
    
    // MARK: Applications
    
    static func setInterview(recordID: UUID, date: Date, location: String, message: String) async throws {
        let update = InterviewUpdate(
            status: statusText(.interview),
            interview_at: date,
            interview_location: location,
            interview_message: message
        )
        try await db.from("applications").update(update).eq("id", value: recordID).execute()
    }
    
    static func setStatus(recordID: UUID, status: EmpAplStatus) async throws {
        try await db.from("applications")
            .update(StatusUpdate(status: statusText(status)))
            .eq("id", value: recordID)
            .execute()
    }
    
    static func removeApplication(recordID: UUID, reason: String) async throws {
        try await db.from("applications")
            .update(RemoveUpdate(rejection_reason: reason))
            .eq("id", value: recordID)
            .execute()
    }
    
    static func withdrawApplication(recordID: UUID) async throws {
        try await db.rpc("withdraw_application", params: WithdrawParam(p_id: recordID)).execute()
    }
}
