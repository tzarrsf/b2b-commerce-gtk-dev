// Get the known good Network (Experience Site) via SOQL
List<Network> networks = [
    SELECT
        Id
        ,Name
        ,Description
        ,AllowedExtensions
        ,CaseCommentEmailTemplateId
        ,ChangePasswordEmailTemplateId
        ,ChgEmailVerNewEmailTemplateId
        ,ChgEmailVerOldEmailTemplateId
        ,CreatedById
        ,CreatedDate
        ,DeviceActEmailTemplateId
        ,EmailFooterLogoId
        ,EmailFooterText
        ,EmailSenderAddress
        ,EmailSenderName
        ,FirstActivationDate
        ,ForgotPasswordEmailTemplateId
        ,HeadlessForgotPasswordTemplateId
        ,LastModifiedById
        ,LastModifiedDate
        ,LockoutEmailTemplateId
        ,MaxFileSizeKb
        ,NewSenderAddress
        ,SelfRegMicroBatchSubErrorEmailTemplateId
        ,SelfRegProfileId
        ,Status
        ,SystemModstamp
        ,UrlPathPrefix
        ,VerificationEmailTemplateId
        ,WelcomeEmailTemplateId
    FROM
        Network
    WHERE
        Name = :TestSettings.KNOWN_GOOD_NETWORK_NAME
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(networks, 'networks is null. Create a known good Network (Experience Site) in the org and check the TestSettings class.');
Assert.isFalse(networks.isEmpty(),  'networks is empty. Create a known good Network (Experience Site) in the org and check the TestSettings class.');
Assert.isTrue(networks.size() == 1, 'networks does not have a single record');
System.Debug('Network Result => ' +  networks[0].Name + ' with size ' + networks.size());