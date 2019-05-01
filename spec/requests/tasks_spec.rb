require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:headers) { { CONTENT_TYPE: "application/json" } }

  context 'valid requests' do
    context 'without present tasks' do
      it 'GET should return empty response' do
        get api_v1_tasks_path
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq({data: []}.as_json)
      end

      it 'POST should create task without tags' do
        task_data = {
          data: {
            id: 'undefined',
            type: 'undefined',
            attributes: { title: 'task_title_1' }
          }
        }

        post api_v1_tasks_path(task_data), headers: headers

        expect(response).to have_http_status(201)

        expected_response_data = {
          data: {
            id: '1',
            type: 'tasks',
            attributes: { title: 'task_title_1' },
            relationships: { tags: { data: [] } }
          }
        }

        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'POST should create tag with task' do
        task_post_data = {
          data: {
            id: 'undefined',
            type: 'undefined',
            attributes: {
              title: 'task_title_1',
              tags: ['task_1_title_1']
            }
          }
        }

        expected_response_data = {
          data: {
            id: '1',
            type: 'tasks',
            attributes: { title: 'task_title_1' },
            relationships: { tags: { data: [ { id: '1', type: 'tags'} ] } }
          },
          included: [
            {
              id: '1',
              type: 'tags',
              attributes: { title: 'task_1_title_1' },
              relationships: { tasks: { data: [ { id: '1', type: 'tasks'} ] } }
            }
          ]
        }

        post api_v1_tasks_path(task_post_data), headers: headers
        expect(response).to have_http_status(201)

        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
        expect(Tag.active.count).to eq(1)
        expect(Task.active.count).to eq(1)
      end
    end

    context 'with present tasks' do
      let!(:tag) { create(:tag) }
      let!(:task) { create(:task) }

      it 'SHOW should return task' do
        get api_v1_task_path(task), headers: headers
        expected_response_data = {
          data: {
            id: "#{task.id}",
            type: 'tasks',
            attributes: { title: "#{task.title}" },
            relationships: { tags: { data: [] } }
          }
        }
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'PATCH should update task title' do
        new_task_title = 'task_title_1'
        task_data = {
          data: {
            id: 'undefined',
            type: 'tasks',
            attributes: { title: new_task_title }
          }
        }

        patch api_v1_task_path(task, task_data), headers: headers

        expect(response).to have_http_status(200)

        expected_response_data = {
          data: {
            id: '1',
            type: 'tasks',
            attributes: { title: new_task_title },
            relationships: { tags: { data: [] } }
          }
        }

        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
      end

      it 'PATCH should add tasks' do
        task_patch_data = {
          data: {
            id: 'undefined',
            type: 'tasks',
            attributes: {
              tags: ['tag_1_title_1']
            }
          }
        }

        expected_response_data = {
          data: {
            id: '1',
            type: 'tasks',
            attributes: { title: task.title },
            relationships: { tags: { data: [ { id: '2', type: 'tags'} ] } }
          },
          included: [
            {
              id: '2',
              type: 'tags',
              attributes: { title: 'tag_1_title_1' },
              relationships: { tasks: { data: [ { id: '1', type: 'tasks'} ] } }
            }
          ]
        }

        patch api_v1_task_path(task, task_patch_data), headers: headers
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(parse_json(expected_response_data.to_json))
        expect(Tag.active.count).to eq(2)
      end

      it 'PATCH should not allow to add existing task' do
        task_patch_data = {
          data: {
            id: 'undefined',
            type: 'tasks',
            attributes: {
              tags: [tag.title]
            }
          }
        }

        patch api_v1_task_path(task, task_patch_data), headers: headers
        expect(response).to have_http_status(422)
        expect(parse_json(response.body)).to eq(["Tags title has already been taken"])
      end

      it 'POST should not allow to add existing tag' do
          task_post_data = {
          data: {
            id: 'undefined',
            type: 'tasks',
            attributes: {
              title: task.title
            }
          }
        }

        post api_v1_tasks_path(task_post_data), headers: headers
        expect(response).to have_http_status(422)
        expect(parse_json(response.body)).to eq(["Title has already been taken"])
      end

      it 'DELETE should mark tag as deleted' do
        delete api_v1_task_path(task), headers: headers
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq(200)
        expect(Task.active.count).to eq(0)
      end

      it 'GET should not show deleted tags' do
        task.mark_as_deleted!
        get api_v1_tasks_path
        expect(response).to have_http_status(200)
        expect(parse_json(response.body)).to eq({data: []}.as_json)
      end
    end
  end

  context 'invalid requests' do
    let!(:tag) { create(:tag) }
    it 'should return 404' do
      get api_v1_task_path(tag), headers: headers
      expect(response).to have_http_status(404)
      expect(parse_json(response.body)).to eq(404)
      expect(Tag.active.count).to eq(1)
    end
  end
end
