class APIIndex {
  /// Auth
  static const String register = "register";
  static const String login = "login";
  static const String forgotPassword = "forgot-password";
  static const String changePassword = "change-password";
  static const String updateProfile = "update-profile";
  static const String validateGST = "validate-gst";

  /// Dashboard
  static const String getCounts = "getCounts";
  static const String listProjects = "list-projects";
  static const String bidOnProject = 'bid-on-project';
  static const String listMyBids = 'list-my-bids';
  static const String interviewTimeline = "get-vendor-interview-timeline";
  static const String getNotifications = 'get-notification';

  /// Candidates
  static const String createCandidateProfile = "create-candidate-profile";
  static const String listVendorCandidates = "listVendorCandidates";
  static const String modifyCandidate = "modifyCandidate";
  static const String removeCandidate = "removeCandidate";
  static const String changeStatusOfCandidateAvailability = "changeStatusOfCandidateAvailability";

  /// Candidates Requirement
  static const String createCandidateRequirement = "create-candidate-requirement";
  static const String updateCandidateRequirement = "update-candidate-requirement";
  static const String listCandidateRequirements = "list-candidate-requirements";
  static const String getCandidateRequirementById = "get-candidate-requirement-by-id";
  static const String deleteCandidateRequirement = "delete-candidate-requirement";
  static const String getRequirementStats = "get-requirement-stats";

  /// Digital Products
  static const String createProduct = "create-digital-product";
  static const String updateProduct = "update-digital-product";
  static const String digitalProducts = "list-digital-products";
  static const String deleteProduct = "delete-digital-product";

  /// Jobs
  static const listPublishedJobs = 'listPublishedJobs';
  static const listStatusWiseCandidateJobs = 'listStatusWiseCandidateJobs';
  static const listOnboardedCandidates = 'listOnboardedCandidates';
  static const getJobAndJobApplicationCounts = 'getJobAndJobApplicationCounts';
  static const applyForJob = 'applyForJob';
  static const submitOnboardingDetails = 'submit-onboarding-details';
}
