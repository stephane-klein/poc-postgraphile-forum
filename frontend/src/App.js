import React from 'react';

import ApolloClient from 'apollo-boost';
import { useQuery } from '@apollo/react-hooks';
import { gql } from 'apollo-boost';

import { ApolloProvider } from '@apollo/react-hooks';

const client = new ApolloClient({
    uri: 'http://127.0.0.1:5000/graphql'
});

function Posts() {
    const { loading, error, data } = useQuery(gql`
        {
            posts {
                nodes {
                    author {
                        fullName
                    }
                    summary
                }
            }
        }
    `);

    if (loading) return <p>Loading...</p>;
    if (error) return <p>Error :(</p>;

    return data.posts.nodes.map((item, i) => (
        <React.Fragment key={i}>
            <div><small>Posted by: {item.author.fullName}</small></div>
            <div>{item.summary}</div>
            <hr />
        </React.Fragment>
    ));
}

function App() {

    return (
        <ApolloProvider client={client}>
            <div>
                <p>Posts:</p>
                <Posts />
            </div>
        </ApolloProvider>
    );
}

export default App;
