using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace WebApplication.Models.Wizards
{
    public partial class PIAWizardViewModel : IValidatableObject
    {
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (!IsCompliantWithDataAgreements())
            {
                yield return new ValidationResult("You must answer questions 1 to 4 with \"yes\"");
            }

            if (DataOwner.UserId == DataCustodian.UserId)
            {
                yield return new ValidationResult("Question 9. Data Owner and Custodian should be different people");
            }

            if (StewardIsAlreadyOwnerOrCustodian())
            {
                yield return new ValidationResult("Question 10. A Data Steward cannot already be the owner or custodian");
            }

            if (DataStewards.Count >= 2)
            {
                if (HasDuplicatedStewardNames())
                {
                    yield return new ValidationResult("Question 11. Each steward should be unique");
                }
            }

            yield return ValidationResult.Success;
        }

        private bool HasDuplicatedStewardNames()
        {
            return DataStewards
                                .GroupBy(ds => ds.UserId)
                                .Any(g => g.Count() > 1);
        }

        private bool StewardIsAlreadyOwnerOrCustodian()
        {
            return DataStewards
                                .Any(ds => ds.UserId == DataOwner.UserId ||
                                ds.UserId == DataCustodian.UserId);
        }

        private bool IsCompliantWithDataAgreements()
        {
            return AuthorisedByDataSubjects && DataAgreementsSigned && UnderstandMetadata
                   && AcceptResponsibility;
        }
    }
}
