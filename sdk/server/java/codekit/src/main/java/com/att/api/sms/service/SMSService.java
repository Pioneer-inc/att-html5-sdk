/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 */

/*
 * ====================================================================
 * LICENSE: Licensed by AT&T under the 'Software Development Kit Tools
 * Agreement.' 2013.
 * TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTIONS:
 * http://developer.att.com/sdk_agreement/
 *
 * Copyright 2013 AT&T Intellectual Property. All rights reserved.
 * For more information contact developer.support@att.com
 * ====================================================================
 */

package com.att.api.sms.service;

import com.att.api.oauth.OAuthToken;
import com.att.api.rest.RESTClient;
import com.att.api.rest.RESTException;
import com.att.api.service.APIService;
import com.att.api.sms.model.SMSGetResponse;
import com.att.api.sms.model.SMSSendResponse;
import com.att.api.sms.model.SMSStatus;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.ParseException;

/**
 * Used to interact with version 3 of the SMS API.
 *
 * <p>
 * This class is thread safe.
 * </p>
 *
 * @author pk9069
 * @version 1.0
 * @since 1.0
 * @see <a href="https://developer.att.com/docs/apis/rest/3/SMS">SMS Documentation</a>
 */
public class SMSService extends APIService {

    /**
     * Creates an SMSService object.
     *
     * @param fqdn fully qualified domain name to use for sending requests
     * @param token OAuth token to use for authorization
     */
    public SMSService(String fqdn, OAuthToken token) {
        super(fqdn, token);
    }

    /**
     * Sends a request to the API for sending an SMS.
     *
     * @param rawAddr addresses to send sms to
     * @param msg message to send
     * @param notifyDeliveryStatus whether to notify of delivery status
     * @return api response
     * @throws RESTException if API request was not successful
     */
    public SMSSendResponse sendSMS(String rawAddr, String msg,
            boolean notifyDeliveryStatus) throws RESTException {

        try {
            return SMSSendResponse.valueOf(new JSONObject(sendSMSAndReturnRawJson(rawAddr, msg, notifyDeliveryStatus)));
        } catch (ParseException pe) {
            throw new RESTException(pe);
        }
    }

    public String sendSMSAndReturnRawJson(String rawAddr, String msg,
            boolean notifyDeliveryStatus) throws RESTException {
        String[] addrs = APIService.formatAddresses(rawAddr);
        JSONArray jaddrs = new JSONArray();
        for (String addr : addrs) {
            jaddrs.put(addr);
        }

        // Build the request body
        JSONObject rpcObject = new JSONObject();
        JSONObject body = new JSONObject();
        body.put("message", msg);

        Object addrStr = addrs.length == 1 ? addrs[0] : jaddrs;
        body.put("address", addrStr);

        body.put("notifyDeliveryStatus", notifyDeliveryStatus);
        rpcObject.put("outboundSMSRequest", body);

        final String endpoint = getFQDN() + "/sms/v3/messaging/outbox";

        final String responseBody = new RESTClient(endpoint)
            .addHeader("Content-Type", "application/json")
            .addAuthorizationHeader(getToken())
            .addHeader("Accept", "application/json")
            .httpPost(rpcObject.toString())
            .getResponseBody();

        return responseBody;
    }    
        
    /**
     * Sends a request for getting delivery status information about an SMS.
     *
     * @param msgId message id used to get status
     * @return api response
     * @throws RESTException if API request was not successful
     */
    public SMSStatus getSMSDeliveryStatus(String msgId) throws RESTException {
        try {
            return SMSStatus.valueOf(new JSONObject(getSMSDeliveryStatusAndReturnRawJson(msgId)));
        } catch (ParseException pe) {
            throw new RESTException(pe);
        }
    }

    public String getSMSDeliveryStatusAndReturnRawJson(String msgId) throws RESTException {
        String endpoint = getFQDN() + "/sms/v3/messaging/outbox/" + msgId;

        final String responseBody = new RESTClient(endpoint)
            .addAuthorizationHeader(getToken())
            .addHeader("Accept", "application/json")
            .httpGet()
            .getResponseBody();
        return responseBody;
    }

    /**
     * Sends a request to the API for getting any messages sent to the
     * specified shortcode.
     *
     * @param registrationID registration id (registered shortcode)
     * @return api response
     * @throws RESTException if API request was not successful
     */
    public SMSGetResponse getSMS(String registrationID) throws RESTException {

        try {
            return SMSGetResponse.valueOf(new JSONObject(this.getSMSAndReturnRawJson(registrationID)));
        } catch (ParseException pe) {
            throw new RESTException(pe);
        }
    }

    public String getSMSAndReturnRawJson(String registrationID) throws RESTException {

        String fqdn = getFQDN();
        String endpoint = fqdn + "/sms/v3/messaging/inbox/" + registrationID;

        final String responseBody = new RESTClient(endpoint)
            .addAuthorizationHeader(getToken())
            .addHeader("Accept", "application/json")
            .httpGet()
            .getResponseBody();
        return responseBody;
    }
}
