using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace PSAdmin.Internal
{
    public enum KevinExceptions {
        DatabaseNotOpen,
        ParameterSetNotFound,
        RowCreate,
        RowUpdate,
        RowDelete,
        ItemExists,
        ItemNotFound,
        ItemNotFoundLookup,
        QuotaExceeded,
        CertificatePrivateKey,
        ParameterNotSet,
        ParameterDefined
        
    }

    public static class KevinBlumenfeldException {
        

        private static Dictionary<KevinExceptions, String> errorStrings = new Dictionary<KevinExceptions, string> {
            { KevinExceptions.DatabaseNotOpen,          "Database not selected" },
            { KevinExceptions.ParameterSetNotFound,     "A Valid ParameterSetName could not be found" },
            { KevinExceptions.RowCreate,                "Unable to create item" },
            { KevinExceptions.RowUpdate,                "Unable to update item" },
            { KevinExceptions.RowDelete,                "Unable to delete item" },
            { KevinExceptions.ItemExists,               "The item already exists '{0}' with property name '{1}'" },
            { KevinExceptions.QuotaExceeded,            "Too many items found matching '{0}' in '{1}'" },
            { KevinExceptions.ItemNotFoundLookup,       "No item found matching '{0}' in '{1}'"},
            { KevinExceptions.ParameterNotSet,          "Parameter '{0}' expected but not defined"},
            { KevinExceptions.ParameterDefined,         "Parameter '{0}' was expected to not be defined"},
            { KevinExceptions.CertificatePrivateKey,    "The Certificate with the Thumbprint of '{0}' does not contain a PrivateKey" }
        };
        private static Dictionary<KevinExceptions, ErrorCategory> errorCategory = new Dictionary<KevinExceptions, ErrorCategory> {
            { KevinExceptions.DatabaseNotOpen,          ErrorCategory.ResourceUnavailable },
            { KevinExceptions.ParameterSetNotFound,     ErrorCategory.InvalidOperation },
            { KevinExceptions.RowCreate,                ErrorCategory.WriteError },
            { KevinExceptions.RowUpdate,                ErrorCategory.WriteError },
            { KevinExceptions.RowDelete,                ErrorCategory.WriteError },
            { KevinExceptions.ItemExists,               ErrorCategory.ResourceExists },
            { KevinExceptions.QuotaExceeded,            ErrorCategory.QuotaExceeded },
            { KevinExceptions.ItemNotFoundLookup,       ErrorCategory.ObjectNotFound },
            { KevinExceptions.ParameterNotSet,          ErrorCategory.InvalidResult },
            { KevinExceptions.ParameterDefined,         ErrorCategory.InvalidResult },
            { KevinExceptions.CertificatePrivateKey,    ErrorCategory.NotEnabled }
        };

        public static ErrorRecord Create(KevinExceptions exceptionType) {
            return Create(errorStrings[exceptionType], exceptionType, "KevinBlumenfeldException", null);
        }
        public static ErrorRecord Create(KevinExceptions exceptionType, params string[] args) {
            return Create(exceptionType, "KevinBlumenfeldException", null, args);
        }
        public static ErrorRecord Create(KevinExceptions exceptionType, string errorId, Exception innerException, params string[] args) 
        {
            return Create(
                String.Format( errorStrings[exceptionType], args), exceptionType, errorId, innerException
            );
        }
        public static ErrorRecord Create(string message, KevinExceptions exceptionType, string errorId, Exception innerException) 
        {
            Exception exception = new Exception(
                message,
                innerException
            );
            return new ErrorRecord(
                exception, errorId, errorCategory[exceptionType], null
            );
        }
    }
    internal static class Resx
    {
        /*
        internal static Dictionary<Exceptions, ErrorItem> Error = new Dictionary<Exceptions, ErrorItem> {
            { ItemNotFound,         "" },
            { ItemNotFoundLookup,   "No item found matching '{0}' in '{1}'" }
        };

        "Unable to "
        */
    }

}