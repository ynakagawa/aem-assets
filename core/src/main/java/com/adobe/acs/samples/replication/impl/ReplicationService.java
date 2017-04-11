package com.adobe.acs.samples.replication.impl;

/**
 * Created by ynaka on 3/27/17.
 */
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;

import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.servlet.ServletException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.day.cq.search.Query;

import org.apache.sling.api.resource.*;
import org.apache.sling.api.servlets.OptingServlet;
import org.apache.sling.commons.json.JSONArray;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.day.cq.search.PredicateGroup;
import com.day.cq.search.QueryBuilder;
import com.day.cq.search.result.Hit;
import com.day.cq.search.result.SearchResult;

/**
 * @author srikrish
 */
@SlingServlet(
        label = "Get All users of AEM",
        description = "Retreive all users in AEM and return usernames as JSON response",
        paths = { "/bin/api/replication" }

)
public class ReplicationService extends SlingAllMethodsServlet implements OptingServlet {

    private static final long serialVersionUID = 5015621601586243628L;
    private static final Logger log = LoggerFactory.getLogger(ReplicationService.class);

    @Override
    protected final void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response) throws
            ServletException, IOException {
        response.setContentType("application/json");
        Session session = request.getResourceResolver().adaptTo(Session.class);
        final QueryBuilder builder = request.getResourceResolver().adaptTo(QueryBuilder.class);
        final String PRICIPALNAME ="rep:principalName";
        final String TYPE="jcr:primaryType";
        final String PATH="/home/users";
        final String USER_PROPERTY="rep:User";

        // Create the query for Querybuilder
        Map<String, String> map = new HashMap<String, String>();
        map.put("path",PATH);
        map.put("property",TYPE);
        map.put("property.value", USER_PROPERTY);
        map.put("p.hits","full");
        map.put("p.limit","-1");
        // Execute query and from the results get the usernames
        Query query = builder.createQuery(PredicateGroup.create(map), session);
        SearchResult result = query.getResult();
        List<String> userList = new ArrayList<String>();
        for (Hit hit : result.getHits()) {
            try {
                ValueMap properties = hit.getProperties();
                userList.add(properties.get(PRICIPALNAME,new String()));

            } catch (RepositoryException e) {
                e.printStackTrace();
            }
        }
        // Build the JSON Response
        JSONArray jsArray = new JSONArray(userList);
        response.getWriter().write(jsArray.toString());
    }

    @Override
    protected final void doPost(SlingHttpServletRequest request, SlingHttpServletResponse response) throws
            ServletException, IOException {
        // Implement custom handling of POST requests
    }

    /** OptingServlet Acceptance Method **/

    @Override
    public final boolean accepts(SlingHttpServletRequest request) {
        /*
         * Add logic which inspects the request which determines if this servlet
         * should handle the request. This will only be executed if the
         * Service Configuration's paths/resourcesTypes/selectors accept the request.
         */
        return true;
    }

}