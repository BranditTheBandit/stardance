# frozen_string_literal: true

# A purchase artifact is intentionally public: anyone with the signed link can
# view it. Enumeration is prevented by the signed id (see ArtifactsController),
# not by this policy.
class ArtifactPolicy < ApplicationPolicy
  def show? = true
end
