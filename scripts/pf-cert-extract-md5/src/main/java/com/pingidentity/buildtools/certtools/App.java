package com.pingidentity.buildtools.certtools;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;

import org.apache.commons.codec.binary.Hex;

public class App {

	public static void main(String [] args) throws KeyStoreException, NoSuchAlgorithmException, CertificateException, IOException
	{
		String keystoreFile = getArg(args, 0, "/Users/ttran/Downloads/16EBEB9A759.p12");
		String password = getArg(args, 1, "2FederateM0re");		
		String keystoreAlias = getArg(args, 2, "ping");
		
		FileInputStream fis = new FileInputStream(keystoreFile);
		
		KeyStore keyStore = KeyStore.getInstance("PKCS12");
		keyStore.load(fis, password.toCharArray());
		
		Certificate[] certificateChain = keyStore.getCertificateChain(keystoreAlias);
		
		System.out.println(hashToHexString(certificateChain[0].getEncoded(), "MD5"));
	}
	
	public static String getArg(String [] args, int argNumber, String defaultValue)
	{
		if(args.length > argNumber)
			return args[argNumber];
		
		return defaultValue;
	}
    
    public static String hashToHexString(final byte[] bytes, final String algo) {
        if (bytes == null) {
            return null;
        }
        final byte[] hashedBytes = hashToBytes(bytes, algo);
        final char[] encodedHex = Hex.encodeHex(hashedBytes);
        return new String(encodedHex);
    }
    
    public static byte[] hashToBytes(final byte[] bytes, final String algo) {
        final MessageDigest digester = getMessageDigester(algo);
        return digester.digest(bytes);
    }
    public static MessageDigest getMessageDigester(final String algo) {
        MessageDigest digester;
        try {
            digester = MessageDigest.getInstance(algo);
        }
        catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
        return digester;
    }
}
