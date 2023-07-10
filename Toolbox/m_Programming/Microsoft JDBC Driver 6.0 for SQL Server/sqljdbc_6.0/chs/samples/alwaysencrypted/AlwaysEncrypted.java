/*=====================================================================
File: 	 AlwaysEncrypted.java
Summary: This Microsoft JDBC Driver for SQL Server sample application
         demonstrates how to create Column Master Key and Column Encryption Key for use 
		 with the Java Key Store for Always Encrypted feature.

---------------------------------------------------------------------
This file is part of the Microsoft JDBC Driver for SQL Server Code Samples.
Copyright (C) Microsoft Corporation.  All rights reserved.
 
This source code is intended only as a supplement to Microsoft
Development Tools and/or on-line documentation.  See these other
materials for detailed information regarding Microsoft code samples.
 
THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.
=====================================================================*/

import java.sql.*;

import javax.xml.bind.DatatypeConverter;

import com.microsoft.sqlserver.jdbc.SQLServerColumnEncryptionJavaKeyStoreProvider;
import com.microsoft.sqlserver.jdbc.SQLServerColumnEncryptionKeyStoreProvider;
import com.microsoft.sqlserver.jdbc.SQLServerException;

/**
 * This program demonstrates how to create Column Master Key (CMK) and Column Encryption Key (CEK)
 * CMK is created first and then it is used to create CEK
 */
public class AlwaysEncrypted
{
	// Alias of the key stored in the keystore.
	private static String keyAlias = "<proide key alias>";

	// Name by which the column master key will be known in the database.
	private static String columnMasterKeyName = "JDBC_CMK";

	// Name by which the column encryption key will be known in the database.
	private static String columnEncryptionKey = "JDBC_CEK";

	// The location of the keystore. 
	private static String keyStoreLocation = "C:\\Dev\\Always Encrypted\\keystore.jks";

	// The password of the keystore and the key.
	private static char[] keyStoreSecret = "********".toCharArray();

	/**
	 * Name of the encryption algorithm used to encrypt the value of
	 * the column encryption key. The algorithm for the system providers must be RSA_OAEP.
	 */
	private static String algorithm = "RSA_OAEP";

	public static void main(String[] args)
	{
		String connectionString = GetConnectionString();
		try
		{
			// Note: if you are not using try-with-resources statements (as here),
			// you must remember to call close() on any Connection, Statement,
			// ResultSet objects that you create.

			// Open a connection to the database.
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			try (Connection sourceConnection = DriverManager.getConnection(connectionString))
			{
				// Instantiate the Java Key Store provider.
				SQLServerColumnEncryptionKeyStoreProvider storeProvider = 
						new SQLServerColumnEncryptionJavaKeyStoreProvider(
								keyStoreLocation,
								keyStoreSecret);

				/**
				 * Create column mater key
				 * For details on syntax  refer: 
				 * https://msdn.microsoft.com/library/mt146393.aspx
				 * 
				 */
				String createCMKSQL = "CREATE COLUMN MASTER KEY " 
						+ columnMasterKeyName
						+ " WITH ( "
						+ " KEY_STORE_PROVIDER_NAME = '" 
						+ storeProvider.getName()
						+ "' , KEY_PATH =  '" 
						+ keyAlias
						+ "' ) ";

				try (Statement cmkStatement = sourceConnection.createStatement())
				{
					cmkStatement.executeUpdate(createCMKSQL);
					System.out.println("Column Master Key created with name : " + columnMasterKeyName);
				}
				
				byte [] encryptedCEK=getEncryptedCEK(storeProvider);

				/**
				 * Create column encryption key 
				 * For more details on the syntax refer: 
				 * https://msdn.microsoft.com/library/mt146372.aspx
				 * Encrypted CEK first needs to be converted into varbinary_literal from bytes, 
				 * for which DatatypeConverter.printHexBinary is used
				 */
				String createCEKSQL = "CREATE COLUMN ENCRYPTION KEY " 
						+ columnEncryptionKey
						+ " WITH VALUES ( "
						+ " COLUMN_MASTER_KEY = " 
						+ columnMasterKeyName
						+ " , ALGORITHM =  '" 
						+ algorithm
						+ "' , ENCRYPTED_VALUE =  0x" 
						+ DatatypeConverter.printHexBinary(encryptedCEK)
						+ " ) ";

				try (Statement cekStatement = sourceConnection.createStatement())
				{
					cekStatement.executeUpdate(createCEKSQL);
					System.out.println("CEK created with name : " + columnEncryptionKey);
				}
			}
		}
		catch (Exception e)
		{
			// Handle any errors that may have occurred.
			e.printStackTrace();
		}
	}

	// To avoid storing the sourceConnection String in your code,
	// you can retrieve it from a configuration file.
	private static String GetConnectionString()
	{

		// Create a variable for the connection string.
		String connectionUrl = "jdbc:sqlserver://localhost:1433;" +
				"databaseName=ae;user=sa;password=********;";

		return connectionUrl;
	}

	private static byte[] getEncryptedCEK(SQLServerColumnEncryptionKeyStoreProvider storeProvider) throws SQLServerException
	{
		/**
		 * Following arguments needed by  SQLServerColumnEncryptionJavaKeyStoreProvider
		 * 1) keyStoreLocation : 
		 * 		Path where keystore is located, including the keystore file name. 
		 * 2) keyStoreSecret : 
		 * 		Password of the keystore and the key.  
		 */
		String plainTextKey = "You need to give your plain text";

		// plainTextKey has to be 32 bytes with current algorithm supported
		byte[] plainCEK = plainTextKey.getBytes();

		// This will give us encrypted column encryption key in bytes
		byte[] encryptedCEK = storeProvider.encryptColumnEncryptionKey(
				keyAlias,
				algorithm,
				plainCEK);

		return encryptedCEK;
	}
}
