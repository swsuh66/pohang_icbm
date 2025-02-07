package com.istec.m1.manager;

import java.io.ByteArrayInputStream;
import java.io.ObjectInputStream;

//import com.sun.xml.internal.fastinfoset.sax.Properties;

public class UdpManager {

	public void receiveByteData(byte[] data) {

		try {

			ByteArrayInputStream bais = new ByteArrayInputStream(data);

			ObjectInputStream ois = new ObjectInputStream(bais);

			//Properties prop = (Properties) ois.readObject(); // 객체 직렬화로 properties 객체를 받아 처리

		} catch (Exception e)

		{

			e.printStackTrace();

		}

	}

}
