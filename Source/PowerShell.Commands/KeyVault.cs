using System;
using PSAdmin;
using PSAdmin.Internal;
using System.Management.Automation;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace PSAdmin.PowerShell.Commands {
    /// <summary>
    /// Creates a PSAdmin KeyVault.
    /// </summary>
    [Cmdlet(VerbsCommon.New, "PSAdminKeyVault")]
    [OutputType(typeof(System.String))]
    public sealed class NewPSAdminKeyVault : PSCmdlet
    {
        /// <summary>
        /// Specify VaultName
        /// </summary>
        [Parameter(Mandatory = true, ValueFromPipeline = true, Position = 0)]
        public string VaultName { get; set; }

        /// <summary>
        /// Specify a Location
        /// </summary>
        [Parameter()]
        public string Location { get; set; }

        /// <summary>
        /// Specify a VaultURI
        /// </summary>
        [Parameter()]
        public string VaultURI { get; set; }

        /// <summary>
        /// Specify SoftDeleteEnabled
        /// </summary>
        [Parameter()]
        public SwitchParameter SoftDeleteEnabled { get; set; }

        /// <summary>
        /// Specify Tags
        /// </summary>
        [Parameter()]
        public String[] Tags { get; set; }

        /// <summary>
        /// Specify Passthru
        /// </summary>
        [Parameter()]
        public SwitchParameter Passthru { get; set; }

        /// <summary>
        /// Begin output
        /// </summary>
        protected override void BeginProcessing()
        {
            if (String.IsNullOrEmpty(Config.SQLConnectionString)) {
                    
                    ArgumentException exception = new System.ArgumentException(
                        "Open-PSAdmin must be called first", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }
        }

        /// <summary>
        /// Process Record
        /// </summary>
        protected override void ProcessRecord()
        {

            Data.KeyVault[] searchvaults = GetPSAdminKeyVault.Call(null, VaultName, true);

            if (searchvaults.Length > 0)
            {
                    ArgumentException exception = new System.ArgumentException(
                        "Item already exists.", "VaultName"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }

            String Id = Guid.NewGuid().ToString().Replace("-", "");

            bool issuccessful = NewPSAdminKeyVault.Call(Id, VaultName, Location, VaultURI, SoftDeleteEnabled, Tags);
            
            if (!issuccessful)
            {
                    ArgumentException exception = new System.ArgumentException(
                        "Could not create Item", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }
            if (Passthru)
            {
                Data.KeyVault[] results = GetPSAdminKeyVault.Call(null, VaultName, true);
                // Unroll the object
                foreach (Data.KeyVault result in results)
                    WriteObject( result );
            }
        }

        /// <summary>
        /// End Processing
        /// </summary>
        protected override void EndProcessing()
        {

        }
        
        public static bool Call(string Id, string VaultName, string Location, string VaultURI, bool SoftDeleteEnabled, string[] Tags)
        {
            // Generate Vault Key
            byte[] VaultKey = new byte[32];
            RNGCryptoServiceProvider.Create().GetBytes(VaultKey);

            Hashtable table = new Hashtable {
                {"Id",                  Id},
                {"VaultName",           VaultName },
                {"Location",            Location },
                {"VaultURI",            VaultURI },
                {"SoftDeleteEnabled",   SoftDeleteEnabled },
                {"VaultKey",            VaultKey}

            };

            if (Tags != null)
                table.Add("Tags",                 String.Join(";", Tags));

            return SQLiteDB.CreateRow("PSAdminKeyVault", table);
        }
    }

    /// <summary>
    /// Returns a PSAdmin KeyVault from the database.
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "PSAdminKeyVault")]
    [OutputType(typeof(System.String))]
    public sealed class GetPSAdminKeyVault : PSCmdlet
    {

        /// <summary>
        /// Specify Id
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public string Id { get; set; }

        /// <summary>
        /// Specify VaultName
        /// </summary>
        [Parameter(ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, Position = 0)]
        public string VaultName { get; set; }

        /// <summary>
        /// Specify search for exact variables
        /// </summary>
        [Parameter()]
        public SwitchParameter Exact { get; set; }

        /// <summary>
        /// Begin output
        /// </summary>
        protected override void BeginProcessing()
        {
            if (String.IsNullOrEmpty(Config.SQLConnectionString)) {
                    
                    ArgumentException exception = new System.ArgumentException(
                        "Open-PSAdmin must be called first", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }

        }

        /// <summary>
        /// Process Record
        /// </summary>
        protected override void ProcessRecord()
        {
            Data.KeyVault[] results = GetPSAdminKeyVault.Call(Id, VaultName, Exact);
            // Unroll the object
            foreach (Data.KeyVault result in results)
                WriteObject( result );
        }

        /// <summary>
        /// End Processing
        /// </summary>
        protected override void EndProcessing()
        {

        }
        
        public static Data.KeyVault[] Call(string Id, string VaultName, bool Exact)
        {
            string filter;

            Hashtable filterTable = new Hashtable {
                {"Id",                  Id},
                {"VaultName",           VaultName },
            };

            filter = SQLiteDB.Filter(filterTable, Exact);
            Data.KeyVault[] result = SQLiteDB.ConvertToType<Data.KeyVault[]>(
                SQLiteDB.GetRow("PSAdminKeyVault", filter)
            );

            return result;
        }
    }

    /// <summary>
    /// Creates a PSAdmin KeyVault.
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "PSAdminKeyVault")]
    [OutputType(typeof(System.String))]
    public sealed class SetPSAdminKeyVault : PSCmdlet
    {
        /// <summary>
        ///
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public string Id {get; set; }

        /// <summary>
        /// Specify VaultName
        /// </summary>
        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0)]
        public string VaultName { get; set; }

        /// <summary>
        /// Specify a Location
        /// </summary>
        [Parameter()]
        public string Location { get; set; }

        /// <summary>
        /// Specify a VaultURI
        /// </summary>
        [Parameter()]
        public string VaultURI { get; set; }

        /// <summary>
        /// Specify SoftDeleteEnabled
        /// </summary>
        [Parameter()]
        public bool SoftDeleteEnabled { get; set; }

        /// <summary>
        /// Specify Tags
        /// </summary>
        [Parameter()]
        public String[] Tags { get; set; }

        /// <summary>
        /// Exact Match
        /// </summary>
        [Parameter()]
        public SwitchParameter Exact { get; set; }

        /// <summary>
        /// Specify Passthru
        /// </summary>
        [Parameter()]
        public SwitchParameter Passthru { get; set; }

        /// <summary>
        /// Begin output
        /// </summary>
        protected override void BeginProcessing()
        {
            if (String.IsNullOrEmpty(Config.SQLConnectionString)) {
                    
                    ArgumentException exception = new System.ArgumentException(
                        "Open-PSAdmin must be called first", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }
        }

        /// <summary>
        /// Process Record
        /// </summary>
        protected override void ProcessRecord()
        {
            bool issuccessful = SetPSAdminKeyVault.Call(Id, VaultName, Location, VaultURI, SoftDeleteEnabled, Tags, Exact);
            
            if (!issuccessful)
            {
                    ArgumentException exception = new System.ArgumentException(
                        "Could not update Item", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }
            if (Passthru)
            {
                Data.KeyVault[] results = GetPSAdminKeyVault.Call(null, VaultName, true);

                // Unroll the object
                foreach (Data.KeyVault result in results)
                    WriteObject( result );
            }
        }

        /// <summary>
        /// End Processing
        /// </summary>
        protected override void EndProcessing()
        {

        }
        
        public static bool Call(string Id, string VaultName, string Location, string VaultURI, bool SoftDeleteEnabled, string[] Tags, bool Exact)
        {
            Hashtable filter = new Hashtable {
                {"Id",                  Id },
                {"VaultName",           VaultName }
            };

            Hashtable table = new Hashtable {
                {"Location",            Location },
                {"VaultURI",            VaultURI },
                {"SoftDeleteEnabled",   SoftDeleteEnabled}
            };

            if (Tags != null)
                table.Add("Tags",                 String.Join(";", Tags));

            return SQLiteDB.UpdateRow("PSAdminKeyVault", table, filter, Exact);
        }
    }

    /// <summary>
    /// Returns a PSAdmin KeyVault from the database.
    /// </summary>
    [Cmdlet(VerbsCommon.Remove, "PSAdminKeyVault", SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.High)]
    [OutputType(typeof(System.String))]
    public sealed class RemovePSAdminKeyVault : PSCmdlet
    {

        /// <summary>
        /// Specify Id
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public string Id { get; set; }

        /// <summary>
        /// Specify VaultName
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true, Position = 0)]
        public string VaultName { get; set; }

        /// <summary>
        /// Specify search for exact variables
        /// </summary>
        [Parameter()]
        public SwitchParameter Match { get; set; }

        /// <summary>
        /// Begin output
        /// </summary>
        protected override void BeginProcessing()
        {
            if (String.IsNullOrEmpty(Config.SQLConnectionString)) {                    
                    ArgumentException exception = new System.ArgumentException(
                        "Open-PSAdmin must be called first", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    ThrowTerminatingError(errorRecord);
            }

        }

        /// <summary>
        /// Process Record
        /// </summary>
        protected override void ProcessRecord()
        {
            Data.KeyVault[] vaults = GetPSAdminKeyVault.Call(Id, VaultName, !Match);

            if ((Match == false) && (vaults.Length < 1)) {
                ArgumentException exception = new System.ArgumentException(
                    "No matches found", "Any"
                );
                ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                WriteError(errorRecord);
            }

            // Unroll the object
            foreach (Data.KeyVault vault in vaults)
            {
                if (!ShouldProcess(vault.VaultName, "Remove"))
                {
                    continue;
                }

                bool IsSuccessful = Call(Id, VaultName, !Match);
                if (!IsSuccessful)
                {
                    ArgumentException exception = new System.ArgumentException(
                        "Could not remove item", "Any"
                    );
                    ErrorRecord errorRecord = new ErrorRecord(exception, "ErrorId", ErrorCategory.InvalidArgument, null);
                    WriteError(errorRecord);
                }

            }
        }

        /// <summary>
        /// End Processing
        /// </summary>
        protected override void EndProcessing()
        {

        }
        
        public static bool Call(string Id, string VaultName, bool Exact)
        {
            string filter;

            Hashtable filterTable = new Hashtable {
                {"Id",                  Id},
                {"VaultName",           VaultName },
            };

            filter = SQLiteDB.Filter(filterTable, Exact);

            return SQLiteDB.RemoveRow("PSAdminKeyVault", filter);
        }
    }
}